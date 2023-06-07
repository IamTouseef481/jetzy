defmodule Data.Helper.MigratorHelperChangeset do
  @moduledoc false
  require Logger
  alias Data.SQL.Repo
  alias Data.Repo, as: MyRepo

  alias Data.Schema.{UserSetting, UniversalUuidMap, UserReferral, UserEvent, UserInterestMeta}
  alias ApiWeb.Utils.Common
  alias Data.Repo.Migrations.FillShareableLinkInUserEvents
  import Mix.Generator, only: [create_file: 2]
  import Macro, only: [underscore: 1]
#  import Bcrypt, only: [hash_pwd_salt: 1]
  import Ecto.Query
  alias Data.Context.{Interests, UserInterests}
  alias Data.Context

  @legacy_vi_key Application.get_env(:data, :legacy)[:legacy_vi_key]
  @legacy_password_hash Application.get_env(:data, :legacy)[:legacy_password_hash]
  @legacy_password_salt Application.get_env(:data, :legacy)[:legacy_password_salt]
  @hash_key Plug.Crypto.KeyGenerator.generate(@legacy_password_hash, @legacy_password_salt, [iterations: 1000, length: 32, digest: :sha])


  @notification_types %{
    1 => "0c0a7251-84de-11ec-8d5d-6113089c0a5b",
    2 => "0c0a7258-84de-11ec-8d5d-6003089c0a5c",
    3 => "0c0a7258-84de-11ec-8d5d-6003089c0a5d",
    4 => "0c0a7258-84de-11ec-8d5d-6003089c0a5e",
    5 => "0c0a7258-84de-11ec-8d5d-6003089c0a5f",
    6 => "0c0a7258-84de-11ec-8d5d-6003089c0c5a",
    7 => "0c0a7258-84de-11ec-8d5d-6003089c0a14",
    8 => "0c0a7258-84de-11ec-8d5d-6003089c0d5a",
    9 => "0c0a7258-84de-11ec-8d5d-6003089c0a15",
    10 => "0c0a7258-84de-11ec-8d5d-6003089c0b5a",
    11 => "0c0a7258-84de-11ec-8d5d-6003089c0e5a"
  }
  @notification_type_strings %{
    1 => "feed_post_comment",
    2 => "feed_shoutout_comment_reply",
    3 => "feed_post_like",
    4 => "user_friend_request",
    5 => "user_message_chat",
    6 => "event_comments",
    7 => "post_tagging",
    8 => "private_group",
    9 => "comment_tagging",
    10 => "friend_request_response",
    11 => "private_group_request"
  }


  @doc "decrypt legacy password and cast to string"
  def make_string_from_hashed_password(hash) do
    decrypt_hash_password(hash)
    |> String.to_charlist()
    |> Enum.reject(& &1 == 0)
    |> to_string
  end

  @doc "decrypt legacy password"
  def decrypt_hash_password(hash) do
    {:ok, bin} = Base.decode64(hash)
    :crypto.crypto_one_time(:aes_256_cbc, mssql_hash_key(), @legacy_vi_key, bin, encrypt: false)
  end

  @doc """
  Legacy MSSQL password hash.
  """
  def mssql_hash_key(), do: @hash_key


  @doc """
  Replace web links with shareable hyperlinks in events and user profiles.
  """
  def fill_shareables() do
    FillShareableLinkInUserEvents.generate_shareable_links_for_events()
    FillShareableLinkInUserEvents.generate_shareable_links_for_users()
  end


  def refresh_user_interest_meta() do
    Interests.get_interest_ids
    |> Enum.each(fn interest_id ->
      with total_members <- UserInterests.get_interest_users_count(interest_id),
      last_member_joined_at <- UserInterests.get_last_member_joined_at(interest_id),
      %UserInterestMeta{} = user_interest_meta <- Context.get_by(UserInterestMeta, [interest_id: interest_id])
      do
        Context.update(UserInterestMeta, user_interest_meta, %{total_members: total_members, last_member_joined_at: last_member_joined_at})
        else
          nil ->
            total_members = UserInterests.get_interest_users_count(interest_id)
            last_member_joined_at = UserInterests.get_last_member_joined_at(interest_id)
            struct(UserInterestMeta)
            |> UserInterestMeta.changeset(%{total_members: total_members, last_member_joined_at: last_member_joined_at, interest_id: interest_id})
            |> Repo.insert()
            # Context.create(UserInterestMeta, %{total_members: total_members, last_member_joined_at: last_member_joined_at})

      end
    end)
  end

  def get_data_starter(original_table, order_by, acc \\ %{}) do
    table = String.upcase(original_table)
    notification_types = @notification_types
    notification_type_strings = @notification_type_strings
    comment_sources = get_db_map("comment_sources")
    like_sources = get_db_map("like_sources")

    with {:ok, %Tds.Result{columns: columns}} <- get_fields(table),
         {:csv, true} <- {:csv, create_rejected_csv_file(table)},
         {:ok, opened_file} <- File.open("apps/data/priv/repo/rejected_data/#{table}.csv", [:write]) do
      fields = columns
               |> Enum.map(fn x -> x |> underscore end)
               |> add_field_id(table)
               |> remove_or_replace_fields(table, columns)
               |> Enum.join(",")
      IO.binwrite(opened_file, ~s(#{fields}\n))

      cond do
        table in ["NOTIFICATIONSETTINGS", "PUSHNOTIFICATIONLOG"] -> get_data(original_table, fields, order_by, notification_types)
        table in ["REWARDOFFER"] -> get_data(original_table, fields, order_by, %{reward_tiers: get_db_map("reward_tier")})
        table in ["INTEREST"] ->
          case get_data(original_table, fields, order_by, acc) do
            %{} = acc ->
              get_data_starter("RegisterUserWithPrivateInterest", "Id", acc)
              get_data_starter("PrivateInterestsCodes", "interestID", acc)
            :ok -> :ok
          end
        table in ["USERSHOUTOUTS"] ->
          user_post_types = get_db_map("user_post_type")
          shoutout_types = get_db_map("shoutout_type")
          get_data(original_table, fields, order_by, %{user_post_types: user_post_types, shoutout_types: shoutout_types})
        table in ["ADDRESSSHOUTOUTMAPPING", "USERSHOUTOUTSTAGGED"] ->
          user_shoutouts = get_db_map("user_shoutouts")
          get_data(original_table, fields, order_by, %{user_shoutouts: user_shoutouts})
        table in ["COMMENTS"] ->
          acc = %{user_shoutouts: get_db_map("user_shoutouts"), comment_sources: comment_sources}
          get_data(original_table, fields, order_by, acc)
        table in ["USERCOMMENTTAGGED"] ->
          acc = %{user_shoutouts: get_db_map("user_shoutouts"), comments: get_db_map("comments"), comment_sources: comment_sources}
          get_data(original_table, fields, order_by, acc)
        table in ["USERSHOUTOUTIMAGE", "USERSHOUTOUTINTEREST", "USERSHOUTOUTSPRIVATE", "TESTMOMENTS"] ->
          acc = %{user_shoutouts: get_db_map("user_shoutouts")}
          get_data(original_table, fields, order_by, acc)
        table in ["REPORTMESSAGES"] ->
          get_data(original_table, fields, order_by, get_db_map("user_shoutouts"))
        table in ["LIKEDETAILS"] ->
          acc =  %{like_sources: like_sources, user_shoutouts: get_db_map("user_shoutouts")}
          get_data(original_table, fields, order_by, acc)
        table in ["USERSHOUTOUTSIMAGES"] ->
          acc =  %{user_shoutouts: get_db_map("user_shoutouts")}
          get_data(original_table, fields, order_by, acc)
        table in ["USERINTEREST"] ->
          acc =  %{interests: get_db_map("interest")}
          get_data(original_table, fields, order_by, acc)
        table in ["USERPREFERENCE"] ->
          acc =  %{user_interest: get_db_map("user_interest")}
          get_data(original_table, fields, order_by, acc)
        table in ["NOTIFICATIONSRECORD"]->
          comments = get_db_map("comments")
          user_shoutouts = get_db_map("user_shoutouts")
          comment_sources = get_db_map("comment_sources")
          acc = %{comments: comments, user_shoutouts: user_shoutouts,
            comment_sources: comment_sources, notification_types: notification_type_strings}
          get_data(original_table, fields, order_by, acc)
        :else -> get_data(original_table, fields, order_by, acc)
      end
    else
      {:error, %Tds.Error{mssql: %{msg_text: msg_text}}} -> {:error, msg_text}
      {:csv, _} -> {:error, "Unable To Create File"}
    end
  end


  defp get_db_map(table, offset \\ 0, map \\ %{}) do
    table = String.upcase(String.replace(table, "_", ""))
    l = 10000
    q = UniversalUuidMap |> select([:int_id, :generated_id]) |> where([u], u.table_name == ^table) |> limit(^l) |> offset(^offset)
    rows = MyRepo.all(q)
    cond do
      Enum.empty?(rows) -> map
      :else ->
        map = Enum.reduce(rows, map, fn row, map ->
          Map.merge(map, %{row.int_id => UUID.binary_to_string!(row.generated_id)})
        end)
        get_db_map(table, offset + l, map)
    end
  end

  defp get_data(original_table, fields, order_by, acc, skip \\ 0, next \\ 1500) do
    file_name = underscore(original_table) <> ".csv"
    table = String.upcase(original_table)
    select_query = select(table)
    binding = String.first(table)
    where_clause = case table do
#      "NOTIFICATIONSRECORD" -> "WHERE Type in(6,7)"
      _ -> ""
    end
    sql = "SELECT #{select_query} FROM #{table} #{binding} #{where_clause} ORDER BY #{binding}.#{order_by} OFFSET #{skip} ROWS FETCH NEXT #{next} ROWS ONLY"
    result = Ecto.Adapters.SQL.query(Repo, sql)
    case result do
      {:error, %Tds.Error{mssql: %{msg_text: msg_text}}} -> {:error, msg_text}
      {:ok, %Tds.Result{rows: []}} -> acc
      {:ok, %Tds.Result{rows: _rows} = result} ->
        resolve_mappings_and_write(table, fields, result, file_name, acc)
        get_data(original_table, fields, order_by, acc, skip + next)
    end
  end

  def get_fields(table) do
    select_query = select(table)
    Ecto.Adapters.SQL.query(Repo, "SELECT TOP 0 #{select_query} FROM #{table}")
  end

  defp select(table) do
    case table do
      "DROPDOWNSUBMASTERTABLE" -> "SubMasterId, MasterId, Name, SortOrder, Status, CreatedOn, UpdatedOn, CreatedBy"
      "USERGEOLOCATION" -> "GeoLocationId, UserId, Location, Latitude, Longitude, CreatedOn, UpdatedOn, IsActualLocation, CityLatLongId"
      "USERGEOLOCATIONLOG" -> "GeoLocationLogId, UserId, Location, Latitude, Longitude, IsActualLocation, CreatedOn, UpdatedOn, LogCreatedOn"
      _ -> "*"
    end
  end

  defp remove_or_replace_fields(columns, table, original_fields) do
    columns =
      columns
      |> replace_fields()
    case table do
      "NOTIFICATIONSRECORD" ->
        columns ++ ["resource_id", "is_read"]
      "COMMENTS" ->
        #In comments we are going to insert shoutout_id at 9
        columns
        |> List.replace_at(8, "updated_by_id")
        |> List.insert_at(9, "shoutout_id")
      "DROPDOWNSUBMASTERTABLE" ->
        columns -- ["created_by", "updated_by"]
        |> List.replace_at(4, "status_id")
      "ELMAH_ERROR" ->
        columns
        |> List.replace_at(3, "error_type")
      "HADCDNMOMENTS" -> columns ++ original_fields |> Enum.map(fn x -> x |> underscore end)
      "HADCDNUSERS" -> columns ++ original_fields |> Enum.map(fn x -> x |> underscore end)
      "NOTIFICATIONSETTINGS" ->
        columns
        |> List.replace_at(3, "is_send_notification")
        |> List.replace_at(4, "is_send_mail")
      "USERMOMENTLIKE" ->
        columns |> List.replace_at(3, "is_liked")
      "USERINTEREST" -> columns |> List.replace_at(1, "user_id")
      "USERREPORT" -> columns |> List.replace_at(3, "report_source_id")
      "PUSHNOTIFICATIONLOG" -> columns |> List.replace_at(3, "notification_type_id")
      "REGISTERUSERWITHPRIVATEINTEREST" -> columns |> List.replace_at(2, "interest_id")
      "USERSHOUTOUTSTAGGED" -> columns |> List.replace_at(2, "user_id")
      "USERCOMMENTTAGGED" -> columns |> List.replace_at(3, "user_id") |> List.insert_at(9, "shoutout_id")
      _ -> columns
    end
  end

  def create_rejected_csv_file(table) do
    create_file("apps/data/priv/repo/rejected_data/#{table}.csv", "")
  end

  defp replace_fields(fields) do
    Enum.map(fields, fn
      "created_date" -> "inserted_at"
      "is_created_on" -> "inserted_at"
      "is_updated_on" -> "updated_at"
      "created_on" -> "inserted_at"
      "updated_on" -> "updated_at"
      "modified_on" -> "updated_at"
      "is_androidor_ios" -> "is_android_ios"
      "iscoolandapealing" -> "is_coolandapealing"
      "last_modified_date" -> "updated_at"
      "last_modifieddate" -> "updated_at"
      "last_modify_date" -> "updated_at"
      "un_sub_scribe" -> "un_subscribe"
      "jobtype" -> "job_type"
      "back_ground_color" -> "background_colour"
      "is_delete" -> "is_deleted"
      "isdeleted" -> "is_deleted"
      "isdownloded" -> "is_downloaded"
      "isfast" -> "is_fast"
      "refferal_code" -> "referal_code"
      "worktype" -> "work_type"
      "moment_langitude" -> "moment_longitude"
      "user_interest_i_ds" -> "user_interest_id"
      "interest_i_d" -> "interest_id"
      "old_moment" -> "is_old_moment"
      "shoutoutid" -> "shoutout_id"
      "master_id" -> "drop_down_master_table_id"
      "api__token" -> "api_token"
      "old__user_id" -> "old_user_id"
      "userid" -> "user_id"
      "total_point" -> "total_points"
      "prefrence_type" -> "preference_type"
      x -> x
    end)
  end

  defp get_binary_to_string(idd) do
    UUID.binary_to_string!(idd)
    rescue
      _ -> idd
  end
  #previously write_data_to_csv_file
  defp resolve_mappings_and_write(table, fields, result, _writing_file, acc) do
    {:ok, opened_file} = File.open("apps/data/priv/repo/rejected_data/#{table}.csv", [:append])
    booleans = get_boolean_fields_index(fields)
    %Tds.Result{rows: _rows} = result
    data = map_fields(result, table, acc)
    updated_acc =
      data
      |> process_booleans(booleans)
      |> Enum.reduce(acc, fn list, acc ->
        [id | _] = list
        {list, updated_acc} = if is_uuid(id) do
          case Tds.Ecto.UUID.cast(id) do
            :error ->
              {List.replace_at(list, 0, get_binary_to_string(id)), acc}
            {:ok, id} ->
              {List.replace_at(list, 0, id), acc}
          end
        else
          {get_check_uuid(table, list), acc}
        end
        list = map_self_pointing_fields(table, fields, list, updated_acc)
        update_or_insert(table, opened_file, fields, list)
        updated_acc
      end)

    if Enum.member?(["REWARDTIER", "USERINTEREST", "INTEREST", "USERPOSTTYPE",
      "SHOUTOUTTYPE", "USERSHOUTOUTS", "ADRESSCOMPONENTS", "ADDRESSSHOUTOUTMAPPING",
      "USERSHOUTOUTSTAGGED", "COMMENTS", "NOTIFICATIONTYPES", "STATUS", "DROPDOWNMASTERTABLE", "USERMOMENTS"], table) do
      File.close(opened_file)
      updated_acc
    else
      File.close(opened_file)
    end
  end

  defp table_model_mapping(table) do
    case table do
      "COMMENTS" -> Data.Schema.Comment
      "NOTIFICATIONSRECORD" -> Data.Schema.NotificationsRecord
      "COMMENTSOURCE" -> Data.Schema.CommentSource
      "USERGEOLOCATION" -> Data.Schema.UserGeoLocation
      "USERGEOLOCATIONLOG" -> Data.Schema.UserGeoLocationLog
      "STATUS" -> Data.Schema.Status
      "NOTIFICATIONTYPES" -> Data.Schema.NotificationType
      "NOTIFICATIONSETTINGS" -> Data.Schema.NotificationSetting
      "PUSHNOTIFICATIONLOG" -> Data.Schema.PushNotificationLog
      "REWARDTIER" -> Data.Schema.RewardTier
      "INTEREST" -> Data.Schema.Interest
      "USERMOMENTS" -> Data.Schema.UserMoment
      "USERPOSTTYPE" -> Data.Schema.UserPostType
      "SHOUTOUTTYPE" -> Data.Schema.ShoutoutType
      "USERSHOUTOUTS" -> Data.Schema.UserEvent
      "ADDRESSSHOUTOUTMAPPING" -> Data.Schema.AddressShoutoutMapping
      "USERSHOUTOUTSTAGGED" -> Data.Schema.UserShoutoutsTagged
      "USERCOMMENTTAGGED" -> Data.Schema.UserCommentTagged
      "USERSHOUTOUTSIMAGES" -> Data.Schema.UserShoutoutsImage
      "USERSHOUTOUTIMAGE" -> Data.Schema.UserShoutoutImage
      "USERSHOUTOUTINTEREST" -> Data.Schema.UserShoutoutInterest
      "USERSHOUTOUTSPRIVATE" -> Data.Schema.UserShoutoutsPrivate
      "TESTMOMENTS" -> Data.Schema.TestMoment
      "REPORTMESSAGES" -> Data.Schema.ReportMessage
      "LIKEDETAILS" -> Data.Schema.LikeDetail
      "DROPDOWNMASTERTABLE" -> Data.Schema.DropDownMasterTable
      "DROPDOWNSUBMASTERTABLE" -> Data.Schema.DropDownSubMasterTable
      "REWARDOFFER" -> Data.Schema.RewardOffer
      "REWARDIMAGES" -> Data.Schema.RewardImage
      "CAREER" -> Data.Schema.Career
      "USERS" -> Data.Schema.User
      "USERSESSION" -> Data.Schema.UserSession
      "COMMENTREPLIES" -> Data.Schema.CommentReply
      "USERCOUNTRY" -> Data.Schema.UserCountry
      "ADDRESSMOMENTMAPPING" -> Data.Schema.AddressMomentMapping
      "ADDRESSCOMPONENT" -> Data.Schema.AddressComponent
      "USERCHATSESSION" -> Data.Schema.UserChatSession
      "USEREMERGENCYCONTACT" -> Data.Schema.UserEmergencyContact
      "USERFRIENDS" -> Data.Schema.UserFriend
      "USERIMAGES" -> Data.Schema.UserImage
      "USERMOMENTSIMAGES" -> Data.Schema.UserMomentsImage
      "USEROFFERTRANSACTION" -> Data.Schema.UserOfferTransaction
      "USERPOINTBALANCE" -> Data.Schema.UserPointBalance
      "USERPROFILEIMAGE" -> Data.Schema.UserProfileImage
      "USERPUSHTOKEN" -> Data.Schema.UserPushToken
      "USERREPORT" -> Data.Schema.UserReport
      "USERREWARDTRANSACTION" -> Data.Schema.UserRewardTransaction
      "SYSDIAGRAMS" -> Data.Schema.SysDiagram
      "MAILCONTENTSETTING" -> Data.Schema.MailContentSetting
      "HADCDNUSERS" -> Data.Schema.HadCdnUser
      "HADCDNMOMENTS" -> Data.Schema.HadCdnMoment
      "EVENTEMAILS" -> Data.Schema.EventEmail
      "ELMAH_ERROR" -> Data.Schema.ElmahError
      "CITYLATLONGS" -> Data.Schema.CityLatLong
      "APIUSERACTIVITYLOG" -> Data.Schema.ApiUserActivityLog
      "REWARDMANAGER" -> Data.Schema.RewardManager
      "ADMIN_TEST" -> Data.Schema.AdminTest
      "ADMIN" -> Data.Schema.Admin
      "USERINTEREST" -> Data.Schema.UserInterest
      "REGISTERUSERWITHPRIVATEINTEREST" -> Data.Schema.RegisterUserWithPrivateInterest
      "PRIVATEINTERESTSCODES" -> Data.Schema.PrivateInterestsCode
      "USERREFERENCE" -> Data.Schema.UserReference
      "SPLASH" -> Data.Schema.Splash
      "ADDRESSCOMPONENTS" -> Data.Schema.AddressComponent
      ""
      _ -> table
    end
  end

  def update_or_insert(table, opened_file, fields, list) do
    model = table_model_mapping(table)
    id = case table do
      table when table in ["sysdiagrams", "SYSDIAGRAMS"] -> Enum.at(list, 2)
      _ -> List.first(list)
    end
    attrs = normalize_before_save(table, Enum.zip(String.split(fields, ","), list) |> Enum.into(%{}))
    obj = case get_record_before_insert(model, id) do
        nil  ->
          struct(model, [id: id]) # Post not found, we build one
        obj -> obj          # Post exists, let's use it
      end
    {cs, _dependent_list} =
      case table do
        "USERS" ->
          dependent_list = [attrs["id"], attrs["user_role"]]
          # attrs = Map.delete(attrs, "user_role")
          {model.changeset(obj, attrs), dependent_list}

        _ ->
          {model.changeset(obj, attrs), []}
      end
    case MyRepo.insert_or_update(cs) do
      {:ok, _} ->
        if table == "USERS" do
          # insert_user_role(dependent_list)
          insert_user_settings(attrs)
          case attrs["referral_code"] do
            nil -> :ok
            _ ->
              fill_user_referral(attrs)
              :ok
          end
        end
      error = {:error, changeset} ->
        Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
        write_rejected_csv(opened_file, list)
    end
#    rescue
#      _all ->
#        write_rejected_csv(opened_file, list)
  end

  # fetch inviter of current user and fill it as referral_code was sent to the user
  defp fill_user_referral(attrs) do
    case MyRepo.get_by(Data.Schema.User , [referral_code: attrs["referral_code"]]) do
      nil  ->
        Logger.warn("User not found for referral code")
        "User not found for referral code"
      inviter ->
        Logger.warn("#{inspect inviter, label: "User found for referral code"}")
        case MyRepo.get_by(UserReferral, [referred_to: attrs["email"], referred_from_id: inviter.id]) do
          nil  ->
            new_id = UUID.uuid1()
            resp = %UserReferral{
              id: new_id,
              referred_to: attrs["email"],
              is_accept: true,
              referred_from_id: inviter.id,
              referral_code: attrs["referral_code"],
#              inserted_at: attrs["inserted_at"],
#              updated_at: attrs["inserted_at"]
            }
            |> UserReferral.changeset(%{})
            |> MyRepo.insert_or_update
            case resp do
              {:ok, _} ->
                Ecto.Adapters.SQL.query(Repo, "update user_referrals ur set inserted_at=#{attrs["inserted_at"]}, updated_at=#{attrs["inserted_at"]} where ur.id=?",
                  UUID.binary_to_string!(new_id))
              e = {:error, changeset} ->
                Logger.error("#{inspect e, label: "saboot"}")
            end
          _ ->
            Logger.error("Looks like referral data already present")
#            Ecto.Adapters.SQL.query(Repo, "update user_referrals ur set inserted_at=#{attrs["inserted_at"]}, updated_at=#{attrs["inserted_at"]}
#            where referred_to=? and referral_code=?", attrs["email"], attrs["referral_code"])
        end
    end
  end

  defp normalize_before_save(table, attrs) do
    case table do
      "USERS" ->
        Map.merge(attrs, %{"is_active"=> true})
      "ELMAH_ERROR" ->
        Map.merge(attrs, %{"inserted_at"=> attrs["time_utc"], "updated_at"=> attrs["time_utc"]})
      "APIUSERACTIVITYLOG" ->
        Map.merge(attrs, %{"inserted_at"=> attrs["when"], "updated_at"=> attrs["when"]})
      "USERSHOUTOUTS" ->
        Map.merge(attrs, %{"image"=> attrs["image_name"] <> "." <> attrs["image_extn"]})
      _ -> attrs
    end
  end

  defp write_rejected_csv(opened_file, list) do
    stringified =
      list
      |> Enum.map(fn x ->
        if is_bitstring(x) do
          if String.length(x) > 0, do: "\"#{String.replace(x, :binary.compile_pattern("\""), "'")}\"", else: x else x
        end
      end)
      |> Enum.join(",")
      |> process_escape_characters()
    IO.binwrite(opened_file, ~s(#{stringified}\n))
  end

  defp map_fields(result, table, acc) do
    %Tds.Result{rows: data} = result
    case table do
      "ADDRESSMOMENTMAPPING" ->
        Enum.map(data, fn list ->
          {address_component_id, _} = List.pop_at(list, 1)
          {moment_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(address_component_id, 1)
          |> convert_and_update_uuids(moment_id, 2)
        end)
      "APIUSERACTIVITYLOG" ->
        Enum.map(data, fn list ->
          {old_user_id, _} = List.pop_at(list, 1)
          {user_id, _} = List.pop_at(list, 13)
          old_user_id = if old_user_id == "00000000-0000-0000-0000-000000000000", do: nil, else: old_user_id
          list
          |> convert_and_update_uuids(old_user_id, 1)
          |> convert_and_update_uuids(user_id, 13)
        end)
      "DROPDOWNSUBMASTERTABLE" ->
        Enum.map(data, fn list ->
          {master_id, _} = List.pop_at(list, 1)
          {status_id, _} = List.pop_at(list, 4)
          list
          |> convert_and_update_uuids(acc[:master_table][master_id], 1)
          |> convert_and_update_uuids(acc[:status][status_id], 4)
        end)
      "HADCDNMOMENTS" ->
        Enum.map(data, fn list ->
          {moment_id, _} = List.pop_at(list, 0)
          list
          |> (fn x -> [UUID.uuid1()] ++ x end).()
          |> convert_and_update_uuids(moment_id, 1)
        end)
      "HADCDNUSERS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 0)
          list
          |> (fn x -> [UUID.uuid1()] ++ x end).()
          |> convert_and_update_uuids(user_id, 1)
        end)
      "NOTIFICATIONSETTINGS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {notification_type_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(acc[notification_type_id], 2)
        end)
      "PRIVATEINTERESTSCODES" ->
        Enum.map(data, fn list ->
          {interest_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(acc[interest_id], 1)
        end)
      "PUSHNOTIFICATIONLOG" ->
        Enum.map(data, fn list ->
          {sender_id, _} = List.pop_at(list, 1)
          {receiver_id, _} = List.pop_at(list, 2)
          {notification_type_id, _} = List.pop_at(list, 3)
          list
          |> convert_and_update_uuids(sender_id, 1)
          |> convert_and_update_uuids(receiver_id, 2)
          |> convert_and_update_uuids(acc[notification_type_id], 3)
        end)
      "REGISTERUSERWITHPRIVATEINTEREST" ->
        Enum.map(data, fn list ->
          {interest_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(acc[interest_id], 2)
        end)
      "SYSDIAGRAMS" ->
        #for definition we did encoding with hex_32 when fetch data than decode it with hex_32
        Enum.map(data, fn list ->
          {definition, _} = List.pop_at(list, 4)
          list = list |> List.replace_at(4, Base.hex_encode32(definition))
          [UUID.uuid1] ++ list
        end)

      "USERREWARDTRANSACTION" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {reward_id, _} = List.pop_at(list, 2)
          list
          |> convert_decimal_to_integer_default_zero(3)
          |> convert_decimal_to_integer_default_zero(4)
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(reward_id, 2)
        end)
      "USERREPORT" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {reported_id, _} = List.pop_at(list, 2)
          {report_source_id, _} = List.pop_at(list, 3)
          report_source_id = if report_source_id == 1, do: "shoutout", else: ""
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(reported_id, 2)
          |> convert_and_update_uuids(report_source_id, 3)
        end)
      "USERREFERENCE" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {interest_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(acc[interest_id], 2)
        end)
      "USERPUSHTOKEN" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {device_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(device_id, 2)
        end)
      "USERPROFILEIMAGE" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(user_id, 1)
        end)
      "USERPREFERENCE" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {user_interest_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(acc[:user_interest][user_interest_id], 2)
          |> convert_and_update_uuids(user_id, 1)
        end)
      "USEROFFERTRANSACTION" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {offer_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(offer_id, 2)
          |> convert_decimal_to_float(3)
          |> convert_decimal_to_float(4)
        end)
      "USERPOINTBALANCE" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_decimal_to_float(2)
        end)
      "USERMOMENTSIMAGES" ->
        Enum.map(data, fn list ->
          {moment_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(moment_id, 1)
        end)
      "USERMOMENTLIKE" ->
        Enum.map(data, fn list ->
          {moment_id, _} = List.pop_at(list, 1)
          {user_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(moment_id, 1)
          |> convert_and_update_uuids(user_id, 2)
        end)
      "USERMOMENTS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 8)
          list
          |> convert_and_update_uuids(user_id, 8)
        end)
      "USERIMAGES" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(user_id, 1)
        end)
      "USERGEOLOCATIONLOG" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(user_id, 1)
        end)
      "USERGEOLOCATION" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {city_lat_long_id, _} = List.pop_at(list, 8)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(city_lat_long_id, 8)
        end)
      "USERFRIENDS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {friend_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(friend_id, 2)
        end)
      "USEREMERGENCYCONTACT" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 4)
          list
          |> convert_and_update_uuids(user_id, 4)
        end)
      "USERLASTACTIVITYLOG" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(user_id, 1)
        end)
      "REWARDIMAGES" ->
        Enum.map(data, fn list ->
          {reward_offer_id, _} = List.pop_at(list, 1)
          if is_binary(reward_offer_id), do: List.replace_at(list, 1, UUID.binary_to_string!(reward_offer_id)), else: list
        end)
      "RESTAURANTS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 2)
        end)
      "USERCHATSESSION" ->
        Enum.map(data, fn list ->
          {first_user_id, _} = List.pop_at(list, 1)
          {second_user_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(first_user_id, 1)
          |> convert_and_update_uuids(second_user_id, 2)
        end)
      "USERSESSION" ->
      Enum.reduce(data, [], fn
        list, acc ->
          {user_id, _} = List.pop_at(list, 1)
          {device_id, _} = List.pop_at(list, 2)
          user_id = translate_binaries(user_id)
          list =
            list
            |> convert_and_update_uuids(user_id, 1)
            |> convert_and_update_uuids(device_id, 2)
          acc ++ [list]
      end)
      "USERCOUNTRY" ->
        Enum.map(data, fn list ->
          {value, _} = List.pop_at(list, 1)
          list
          |> convert_and_update_uuids(value, 1)
        end)
      "REWARDOFFER" ->
        Enum.map(data, fn list ->
          {tier_id, _} = List.pop_at(list, 3)
          {_reward_offer, _} = List.pop_at(list, 7)
          list
#          |> List.replace_at(7, Base.hex_encode32(reward_offer))
          |> convert_and_update_uuids(acc[:reward_tiers][tier_id], 3)
        end)
      "USERINTEREST" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 1)
          {interest_id, _} = List.pop_at(list, 2)
          list
          |> convert_and_update_uuids(user_id, 1)
          |> convert_and_update_uuids(acc[:interests][interest_id], 2)
        end)
      "USERS" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 0)
          list
          |> convert_and_update_uuids(user_id, 0)
          |> (fn f ->
            # {hashed_pwd, _} = List.pop_at(f, 6)
            # converted_pwd = case make_string_from_hashed_password(hashed_pwd) do
            #   "" -> ""
            #   data -> data |> hash_pwd_salt()
            # end
            # f = List.replace_at(f, 6, converted_pwd)
            f = case List.last(f) do
              nil -> List.replace_at(f, -1, false)
              "0" -> List.replace_at(f, -1, true)
              _ -> List.replace_at(f, -1, false)
            end
            List.update_at(f, 4, fn
              :male -> "male"
              :female -> "female"
              "1" ->  "male"
              "2" -> "female"
              _ -> "none"
            end)
              end).()
        end)
      "ADRESSCOMPONENTS" ->
        Enum.map(data, fn list ->
          {address_component_id , _} = List.pop_at(list, 0)
          convert_and_update_uuids(list, address_component_id, 0)
        end)
      "ADDRESSSHOUTOUTMAPPING" ->
        Enum.map(data, fn list ->
#          {shoutout_mapping_id , _} = List.pop_at(list, 0)
          {address_component_id, _} = List.pop_at(list, 1)
          {shoutout_id, _} = List.pop_at(list, 2)
          list
#          |> convert_and_update_uuids(shoutout_mapping_id, 0)
          |> convert_and_update_uuids(address_component_id, 1)
          |> convert_and_update_uuids(acc[:user_shoutouts][shoutout_id], 2)
        end)
      "USERSHOUTOUTS" ->
        Enum.map(data, fn list ->
          {shoutout_guid, _} = List.pop_at(list, 1)
          {user_id, _} = List.pop_at(list, 2)
          {updated_by, _} = List.pop_at(list, 15)
          {shoutout_type_id, _} = List.pop_at(list, 3)
          {post_type_id, _} = List.pop_at(list, 16)
          list
          |> convert_and_update_uuids(shoutout_guid, 1)
          |> convert_and_update_uuids(user_id, 2)
          |> convert_and_update_uuids(updated_by, 15)
          |> convert_and_update_uuids(acc[:shoutout_types][shoutout_type_id], 3)
          |> convert_and_update_uuids(acc[:user_post_types][post_type_id], 16)
        end)
      "USERSHOUTOUTSTAGGED" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 1)
          {user_id, _} = List.pop_at(list, 2)

          list
          |> update_boolean_values([5]) #at index 5 FLAG is integer needs to make it boolean
          |> convert_and_update_uuids(acc[:user_shoutouts][shoutout_id], 1)
          |> convert_and_update_uuids(user_id, 2)
        end)
      "USERCOMMENTTAGGED" ->
        Enum.map(data, fn list ->
          {comment_source_id, _} = List.pop_at(list, 2)
          {parent_id, _} = List.pop_at(list, 1)
          {user_id, _} = List.pop_at(list, 3)
          list =
            list
            |> convert_and_update_uuids(user_id, 3)
            |> List.insert_at(9, nil)
          case comment_source_id
            do
            1 ->
              # if comment_source_id is 1 then parent_id belongs to user_shoutouts table; replace it accordingly
              list
              |> List.replace_at(1, nil)
              |> convert_and_update_uuids(acc[:user_shoutouts][parent_id], 9)
            2 ->
              convert_and_update_uuids(list, acc[:comments][parent_id], 1)
            # if comment_source_id is 2 then parent_id belongs to comments table; it will be replaces afterwards
            _ -> list
          end
          |> convert_and_update_uuids(acc[:comment_sources][comment_source_id], 2)
          |> update_boolean_values([6]) #at index 6 FLAG is integer needs to make it boolean
        end)

      "USERSHOUTOUTSIMAGES" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 1)
          convert_and_update_uuids(list, acc[:user_shoutouts][shoutout_id], 1)
        end)
      "USERSHOUTOUTIMAGE" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 1)
          convert_and_update_uuids(list, acc[:user_shoutouts][shoutout_id], 1)
        end)
      "USERSHOUTOUTINTEREST" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 1)
          convert_and_update_uuids(list, acc[shoutout_id], 1)
        end)
      "USERSHOUTOUTSPRIVATE" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 1)
          convert_and_update_uuids(list, acc[:user_shoutouts][shoutout_id], 1)
        end)
      "TESTMOMENTS" ->
        Enum.map(data, fn list ->
          {shoutout_id, _} = List.pop_at(list, 15)
          {user_id, _} = List.pop_at(list, 8)
          list
          |> convert_and_update_uuids(acc[:user_shoutouts][shoutout_id], 15)
          |> convert_and_update_uuids(user_id, 8)
        end)
      "REPORTMESSAGES" ->
        Enum.map(data, fn list ->
          {user_id, _} = List.pop_at(list, 2)
          {item_id, _} = List.pop_at(list, 3)
          list
          |> List.replace_at(1, "shoutout")
          |> convert_and_update_uuids(user_id, 2)
          |> convert_and_update_uuids(acc[item_id], 3)
        end)
      "NOTIFICATIONSRECORD" ->
        Enum.map(data, fn list ->
          {sender_id, _} = List.pop_at(list, 1)
          {receiver_id, _} = List.pop_at(list, 2)
          {type_id, _} = List.pop_at(list, 4)
          {description, _} = List.pop_at(list, 3)
          {shoutout_id, _} = List.pop_at(list, 10)
          type_id = get_int_value(type_id)
          shoutout_id = get_int_value(shoutout_id)
          list =
            list
          |> convert_and_update_uuids(sender_id, 1)
          |> convert_and_update_uuids(receiver_id, 2)
          |> List.replace_at(4, change_notification_records_type(type_id, description, acc[:notification_types]))
            |> List.insert_at(17, nil) #initialization so that replace_at can work
            |> List.insert_at(18, true) #mark is_read to true for all notifications coming form old db
          # new_shoutout_id = acc[:user_shoutouts][shoutout_id]
          case type_id do
               6 -> convert_and_update_uuids(list, acc[:user_shoutouts][shoutout_id], 17)
               7 -> convert_and_update_uuids(list, acc[:user_shoutouts][shoutout_id], 17)
            _ ->
              List.replace_at(list, 17, nil)
          end
        end)
      "LIKEDETAILS" ->
        Enum.map(data, fn list ->
          {like_id, _} = List.pop_at(list, 1)
          {item_id, _} = List.pop_at(list, 2)
          {user_id, _} = List.pop_at(list, 4)
          list
          |> convert_and_update_uuids(acc[:like_sources][like_id], 1)
          |> convert_and_update_uuids(acc[:user_shoutouts][item_id], 2)
          |> convert_and_update_uuids(user_id, 4)
          end)
      "CITYLATLONGS" ->
        Enum.map(data, fn list ->
          list
          |> convert_decimal_to_float(6) #lat
          |> convert_decimal_to_float(7)  #lon
        end)
      "ADMIN_TEST" ->
        Enum.map(data, fn list ->
          list = convert_decimal_to_integer_default_nil(list, 8)
          {role_id, _} = List.pop_at(list, 8)
          role_id = case role_id do
            0 -> "user"
            1 -> "admin"
            _ -> "guest"
          end
          List.replace_at(list, 8, role_id)
        end)
      _ ->
        data
    end
  end
  defp convert_decimal_to_float(list, index) do
    {item, _} = List.pop_at(list, index)
    case Decimal.cast(item) do
      {:ok, decimal} ->
        List.replace_at(list, index, Decimal.to_float(decimal))
      :error -> List.replace_at(list, index, nil)
      _ -> list
    end
  end
  #if decimal replace index with int value, otherwise replace with nil
  defp convert_decimal_to_integer_default_zero(list, index) do
    {item, _} = List.pop_at(list, index)
    List.replace_at(list, index, Decimal.to_integer(item))

#    case Decimal.cast(item) do
#      {:ok, decimal} ->
#        List.replace_at(list, index, Decimal.to_integer(decimal))
#      :error -> List.replace_at(list, index, 0)
#      _ -> list
#    end
  end
  #if decimal replace index with int value, otherwise replace with nil
  defp convert_decimal_to_integer_default_nil(list, index) do
    {item, _} = List.pop_at(list, index)
    case Decimal.cast(item) do
      {:ok, decimal} ->
        List.replace_at(list, index, Decimal.to_integer(decimal))
      :error -> List.replace_at(list, index, nil)

      #      _ -> list
    end
  end

  defp get_int_value(item) do
    if is_nil(item) do
        item
      else
      case Integer.parse(item) do
        {an_integer, _} -> an_integer
        _ -> item
      end
    end
  end

  #this fn will resolve self pointing fields. comment can be child of a comment;
  #in this case if parent comment is not yet added into acc we cannot replace its uuid
  defp map_self_pointing_fields(table, _fields, list, acc) do
    case table do
      "COMMENTS" ->
        {comment_source_id, _} = List.pop_at(list, 1)
        {user_id, _} = List.pop_at(list, 2)
        {parent_id, _} = List.pop_at(list, 4)
        {updated_by, _} = List.pop_at(list, 8)
        #In comments we are going to insert shoutout_id at 9
        list =
          list
          |> List.insert_at(9, nil)
#          |> update_boolean_values([5]) #is_deleted needs a value
          |> convert_and_update_uuids(user_id, 2)
          |> convert_and_update_uuids(updated_by, 8)
          |> convert_and_update_uuids(acc[:comment_sources][comment_source_id], 1)
        case comment_source_id
          do
          1 ->
            # if comment_source_id is 1 then parent_id belongs to user_shoutouts table; replace it accordingly
          list
          |> List.replace_at(4, nil)
          |> convert_and_update_uuids(acc[:user_shoutouts][parent_id], 9)

          2 ->
            case check_uuid(table, parent_id) do
              false -> List.replace_at(list, 4, nil)
              v -> List.replace_at(list, 4, v)
            end
          # if comment_source_id is 2 then parent_id belongs to comments table; it will be replaces afterwards
          _ -> list
        end

      _ -> list
    end
  end
  defp process_booleans(data, boolean_indexes) do
    Enum.map(data, fn list ->
      update_boolean_values(list, boolean_indexes)
    end)
  end
  defp update_boolean_values(list, boolean_indexes) do
    Enum.reduce(boolean_indexes, list, fn index, acc ->
      List.update_at(acc, index, fn
        case when case in ['', "", "0", nil] -> false
        l when is_boolean(l) -> l
        1 -> true
        "1" -> true
        _ -> false
      end)
    end)
  end
  defp get_boolean_fields_index(fields) do
    f = fields |> String.split(",")
    f
    |> Enum.filter(fn x -> String.starts_with?(x, "is_") end)
    |> Enum.map(fn bool -> Enum.find_index(f, fn x -> x == bool end) end)
  end

  # @todo remove after may 2022
  #  defp insert_user_role(list) do
  #    user_id = List.first(list)
  #    {value, _} = List.pop_at(list, 1)
  #    role_id = case value do
  #      0 -> "user"
  #      1 -> "admin"
  #      _ -> "guest"
  #    end
  #    id = UUID.uuid1()
  #    obj = case MyRepo.get_by(UserRole , [user_id: user_id, role_id: "#{role_id}"]) do
  #      nil  ->
  #        %UserRole{id: id, user_id: user_id, role_id: "#{role_id}",
  #          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
  #           updated_at: DateTime.truncate(DateTime.utc_now(), :second)}
  #      obj -> obj          # obj exists, let's use it
  #    end
  #    resp =
  #      obj
  #      |> UserRole.changeset(%{user_id: user_id, role_id: "#{role_id}"})
  ##            inserted_at: DateTime.truncate(obj.inserted_at, :second),
  ##            updated_at: DateTime.truncate(obj.updated_at, :second)})
  #      |> MyRepo.insert_or_update
  #    case resp do
  #      {:ok, _} -> :ok
  #      {:error, changeset} -> changeset
  ##            write_rejected_csv(opened_file, list)
  #    end
  #    list
  #    rescue
  #      _ -> list
  #  end

  defp insert_user_settings(user_map) do
    user_map = %{
      user_invite_type: user_map["user_inivite_type"],
      user_id: user_map["id"],
      is_push_notification: user_map["is_push_notification"],
      is_groupchat_enable: user_map["is_groupchat_enable"],
      is_show_on_profile: user_map["is_show_on_profile"],
      is_moments_enable: user_map["is_moments_enable"],
      is_profile_image_sync: user_map["is_profile_image_sync"],
      is_enable_chat: user_map["is_enable_chat"],
      is_info: user_map["is_info"],
#      user_invite_type: user_map["user_invite_type"],
      un_subscribe: user_map["un_subscribe"]
    }

    user_id = user_map.user_id
    obj = case MyRepo.get_by(UserSetting , [user_id: user_id]) do
      nil  ->
        %UserSetting{id: UUID.uuid1(), user_id: user_id}
      obj -> obj          # obj exists, let's use it
    end
    resp =
      obj
      |> UserSetting.changeset(user_map)
      |> MyRepo.insert_or_update
    case resp do
      {:ok, _} -> :ok
      {:error, changeset} -> changeset
    end
    # rescue
    #   _ -> user_map
  end
  defp is_uuid(binary) do
    case UUID.info(binary) do
      {:error, _} -> false
      {:ok, _} -> true
    end
  end
  #check uuid in db otherwise generate and save into db
  defp get_check_uuid(table, list) do
    table = String.upcase(String.replace(table, "_", ""))
    {item, _} = List.pop_at(list, 0)
    int_id = case Decimal.cast(item) do
      {:ok, decimal} -> Decimal.to_integer(decimal)
      _ -> item
    end
    uuid = case MyRepo.get_by(UniversalUuidMap , [int_id: int_id, table_name: "#{table}"]) do
      nil  ->
        uuid = UUID.uuid1()
        obj = %UniversalUuidMap{int_id: int_id, table_name: "#{table}", generated_id: UUID.string_to_binary!(uuid),
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)}
        MyRepo.insert_or_update(UniversalUuidMap.changeset(obj))
        uuid
      obj ->
        UUID.binary_to_string!(obj.generated_id)
    end
    List.replace_at(list, 0, uuid)
  end

  #check uuid in db otherwise return false
  defp check_uuid(table, int_id) do
    table = String.upcase(String.replace(table, "_", ""))
    _uuid = case MyRepo.get_by(UniversalUuidMap , [int_id: int_id, table_name: "#{table}"]) do
      nil  ->
        false
      obj ->
        UUID.binary_to_string!(obj.generated_id)
    end
  end
  defp convert_and_update_uuids(list, value, index, to_binary \\ false) do
      if is_nil(value) do
        List.replace_at(list, index, value)
        else
        case Tds.Ecto.UUID.cast(value) do
          :error -> list
          {:ok, v} ->
            v = if to_binary, do: UUID.string_to_binary!(v), else: v
            List.replace_at(list, index, v)
        end
      end
  end
  defp process_escape_characters(list) do
    list
    |> String.replace("\a", "\\a")
    |> String.replace("\n", "\\n")
    |> String.replace("\b", "\\b")
    |> String.replace("\f", "\\f")
    |> String.replace("\r", "\\r")
    |> String.replace("\t", "\\t")
    |> String.replace("\v", "\\v")
#    |> String.replace("\'", "\\'")
    |> String.replace("\?", "\\?")
  end
  defp translate_binaries(uuid) do
    case Tds.Ecto.UUID.cast(uuid) do
      :error -> :error
      {:ok, value} -> value
    end
  end

  defp get_record_before_insert(model, id) do
    case model do
      Data.Schema.SysDiagram -> MyRepo.get_by(model, principal_id: id)
      _ -> MyRepo.get(model, id)
    end
  end

  defp add_field_id(fields, table) do
    case table do
      table when table in ["sysdiagrams", "SYSDIAGRAMS"] -> List.insert_at(fields, 0, "id")
      _ -> List.replace_at(fields, 0, "id")
    end
  end
  defp change_notification_records_type(type_id, description, notification_types) do
    case type_id do
      6 ->
        if String.contains?(description, "like") do
          "feed_post_like"
        else
          "feed_post_comment"
        end
      8 ->
        if String.contains?(description, "added") do
          "private_group_request_received"
        else
          "private_group_invitation_response"
        end
      _ -> notification_types[type_id]
    end
  end
  def import_csv(csv_path, table) do
    base_path = "apps/data/priv/repo/seeds/"
    table = String.upcase(String.replace(table, "_", ""))
    create_rejected_csv_file(table)

      (csv_path <> ".csv")
      |> Path.expand(base_path)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Stream.each(fn row ->
        row
        |> map_to_table2(table)
      end)
      |> Stream.run()
  end

  def map_to_table2(map, table) do
    model = table_model_mapping(table)
    ev = map["event"]
    obj = case MyRepo.get_by(model, event: ev) do
      nil  ->
        struct(model, [id: UUID.uuid1()]) # Model not found, we build one
      obj -> obj
    end
    cs = model.changeset(obj, map)
    resp = MyRepo.insert_or_update(cs)
    case resp do
      {:ok, _} -> :ok
      {:error, changeset} -> changeset
    end
  rescue
    all -> all
  end
end
