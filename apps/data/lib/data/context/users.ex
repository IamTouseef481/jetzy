defmodule Data.Context.Users do
  import Ecto.Query, warn: false

  import Bcrypt, only: [verify_pass: 2]
  require Logger

  alias Data.Repo
  alias Data.Context
  alias Data.Context.UserBlocks
  alias Data.Schema.{User, UserInterest, UserRole, UserFollow, UserSocialAccount, UserImage,
  UserGeoLocationLog, UserGeoLocation, ReportMessage, Interest, UserReferralCodeLog, UserReferral, UserContact}

  alias Data.Context.{Users, UserReferrals, UserImages, UserInstalls, GuestInterests, UserEvents, UserFollows,
                      PushNotificationLogs, NotificationsRecords, Interests, InterestTopics,
                      Rooms, RoomMessages, RoomMessageMetas}
  

#  alias Data.Schema.UserFriend
#  alias Data.Schema.UserBlock
#  alias Data.Schema.ObanJob
  alias Api.Guardian
  alias Api.Helper.UsersSearch
  import Ecto.Multi, except: [inspect: 2]


  @referral_code_url Application.get_env(:api, :configuration)[:referral_code_url]
  @profile_create_reward "6eb58c08-5a90-4847-9059-f3392cdb550e"

  @spec preload_all(User.t()) :: User.t()
  def preload_all(data) do
    user_images_query = UserImage
    |> where([ui], not is_nil(ui.images) and ui.is_deleted == false)
    |> order_by([ui], [desc: ui.order_number])
      Repo.preload(data, [
        :comments,
        # :comment_likes,
        # :report_messages,
        :user_country,
        :user_emergency_contact,
        :user_filters,
#        :user_follows,
       :user_geo_locations,
       :user_geo_location_logs,
        :user_inquiries,
        :user_interests,
        :user_prefered_interests,
        :user_prefereces,
        :user_profile_images,
        :user_shoutouts,
        # :user_friends,
        :interests,
        user_images: user_images_query
      ])
  end




  def perform_task(handle, task, _context \\ nil, options \\ []) do
    cond do
      options[:sync] -> task.()
      options[handle] == :sync -> task.()
      :else -> Task.start(fn -> task.() end)
    end
  rescue error ->
    Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
    {:error, {:exception, error}}
  catch
    error ->
      Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
      {:error, {:exception, error}}
    _, error ->
      Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
      {:error, {:exception, error}}
  end

  #----------------------------------------------------------------------------
  # clear_deleted_user
  #----------------------------------------------------------------------------
  @doc """
    @todo move user to deleted_user table.
  """
  def clear_deleted_user(user, _context, options \\ []) do
    email = options[:updated_email] || "#{user.email}#del-#{:os.system_time(:second)}"
    Data.Context.update(User, user, %{email: email})
  rescue error ->
    Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
    {:error, {:exception, error}}
  catch
    error ->
      Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
      {:error, {:exception, error}}
    _, error ->
      Logger.warn("#{__MODULE__}:#{__ENV__.line} Exception Raised #{Exception.format(:error, error, __STACKTRACE__)}")
      {:error, {:exception, error}}
  end

  
  
  def register_user(request, context, options \\ nil) do
    if email_exists?(request["email"]) do
      case Context.get_by(User, [email: request["email"]]) do
        %User{is_deleted: true} -> {:error, :deleted}
        %User{is_deactivated: true} -> {:error, :deactivated}
        %User{is_self_deactivated: true} -> {:error, :self_deactivated}
        %User{} -> {:error, :exists}
      end
    else
      # Setup user.
      with request <- Map.put(request, "password", Bcrypt.hash_pwd_salt(request["password"])),
           {user_image, user_thumb, blur_hash} <- upload_profile_image_extended(request),
           request <- Map.merge(request, %{"image_name" => user_image, "small_image_name" => user_thumb, "blur_hash" => blur_hash}),
           request <- register_user__check_referral(request, context, options),
           {:ok, %User{} = user} <- Context.create(User, request),
           {:ok, %{__struct__: _}} <- User.create_user_role(user, options[:role] || "user"),
           {:ok, %Data.Schema.UserImage{} = _profile_image} <- User.create_user_profile_image_extended(user, {nil, user_image, user_thumb, blur_hash}, 1),
           {:ok, _} <- User.create_user_settings(user),
           {:ok, _} <- User.create_notification_settings(user),
           _ <- make_shareable_link(user),
           _ <- make_direct_login_link(user) do
        {:ok, {user, request}}
      else
        e -> e
      end
    end
  end
  
  @doc """
  We really shouldn't be updating the referral entries and points until after successful user creation.
  """
  def register_user__check_referral(request, context, options) do
    params = request
    case UserReferrals.verify(params["email"], params["referral_code"]) do
      {:ok, {status, details}} ->
        params = case status do
                   :accepted ->
                     params
                     |> Map.put("friend_code", params["referral_code"])
                   :invite ->
                     Context.update(UserReferral, details, %{is_accept: true})
                     Data.Context.RewardManagers.update_points(details.referred_from_id, :sign_up_through_referral)
                     params
                     |> Map.put("friend_code", params["referral_code"])
                   :new ->
                     Context.create(UserReferral, %{is_accept: true, referred_to: params["email"],
                       referral_code: params["referral_code"], referred_from_id: details.id})
                     Data.Context.RewardManagers.update_points(details.id, :sign_up_through_referral)
                     params
                 end
        params
        |> Map.put("is_referral", true)
        |> Map.put("is_active", true)
      _ ->
        params
        |> Map.put("is_referral", false)
        |> Map.put("is_active", false)
    end
  end


  def make_direct_login_link(user) do
    Task.start(fn ->
      dsl = Data.Helper.generate_url("direct-login", user.id)
      user
      |> User.changeset(%{direct_login_link: dsl})
      |> Repo.insert_or_update
    end)
  end

  def make_shareable_link(user) do
    Task.start(fn ->
      sl = Data.Helper.generate_url("user", user.id)
      user
      |> User.changeset(%{shareable_link: sl})
      |> Repo.insert_or_update
    end)
  end
  
  
  
  #----------------------------------------------------------------------------
  # create_user
  #----------------------------------------------------------------------------
  def create_user_from_request(request, context, options \\ []) do
      params = Map.put(request, "password", Bcrypt.hash_pwd_salt(request["password"]))

      with params <- create_user_from_request__verify_referral(request, context, options),
           {:ok, profile_image} <- Users.save_profile_image(params, context, options),
           {:ok, %User{} = user} <- Context.create(User, params),
           {:ok, %{__struct__: _}} <- User.create_user_role(user, params["role"] || "user"), # @audit this looks like a security risk
           {:ok, _} <- User.create_user_installs(user, params),
           {:ok, _} <- User.create_user_profile_image_record(user, profile_image, context, options),
           {:ok, _} <- User.create_user_settings(user),
           {:ok, _} <- User.create_notification_settings(user)
        do
        # Send welcome email
        perform_task(:send_welcome_email, fn -> create_user_from_request__send_welcome_email(user, params, context, options) end, context, options)

        #generate and save shareable link
        perform_task(:user_share_link, fn -> create_user_from_request__make_shareable_link(user, context, options) end, context, options)

        #generate and save direct_shareable_link
        perform_task(:direct_login_link, fn -> create_user_from_request__make_direct_login_link(user, context, options) end, context, options)

        if device_token = params["installs"]["device_token"] do
          perform_task(:create_user_interests, fn -> create_user_from_request__create_user_interests(user, device_token, context, options) end, context, options)

          # Clear Guest Details
          perform_task(:delete_guest_interests, fn -> GuestInterests.delete_guest_interests_by_device_id(device_token) end, context, options)
        end
        # Send profile setup reminder if user details not populated.
        perform_task(:profile_setup_reminder, fn -> create_user_from_request__profile_setup_reminder(user, context, options) end, context, options)

        # Send Sign Up Reward points.
        perform_task(:sign_up_reward , fn -> JetzyModule.JetzyPointsModule.sign_up_reward(user, context) end, context, options)

        {:ok, user}
      else
        exception -> exception
      end
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__profile_setup_reminder
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__profile_setup_reminder(user, _, _) do
    if is_nil(user.first_name) || is_nil(user.last_name) do
      push_notification_params = %{
        "keys" => %{},
        "event" => "profile_reminder", "user_id" => user.id, "schedule_time" => 1,
        "worker_name" => PushNotificationSignupWorker,
        "sender_id" => user.id
      }
      ApiWeb.Utils.PushNotification.schedule_push_notification(push_notification_params)
    end
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__create_user_interests
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__create_user_interests(user, device_id, _, _) do
    user_id = user.id
    case GuestInterests.get_guest_interest_by_device_id(device_id) do
      interests when is_list(interests) ->
        interests
        |> Enum.uniq()
        |> Task.async_stream(fn(interest) ->
          try do
            cond do
              existing = Data.Repo.get_by(UserInterest, [user_id: user_id, interest_id: interest]) -> existing
              :else ->
                case Context.create(UserInterest, %{user_id: user_id, interest_id: interest}) do
                  e = {:error, _} ->
                    Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{inspect e, limit: :infinty, pretty: true}")
                    nil
                  {:ok, v} -> v
                  v -> v
                end
            end
          rescue error ->
            Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
          catch
            error ->
              Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
            _, error ->
              Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
          end
        end)
        |> Enum.map(
             fn
               ({:ok, v}) -> v
               (_) -> nil
             end)
        |> Enum.filter(&(&1))
      _ -> :do_nothing
    end
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__make_direct_login_link
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__make_direct_login_link(user, _, options) do
      dsl = options[:direct_login_link] || Data.Helper.generate_url("direct-login", user.id)
      user
      |> User.changeset(%{direct_login_link: dsl})
      |> Repo.insert_or_update
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__make_shareable_link
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__make_shareable_link(user, _, options) do
      user
      |> User.changeset(%{shareable_link: options[:share_link] || Data.Helper.generate_url("user", user.id)})
      |> Repo.insert_or_update
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__verify_referral
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__verify_referral(params, _, _) do
    if params["referral_code"] do
      case UserReferrals.check_record(params["email"], params["referral_code"]) do
        %Data.Schema.UserReferral{} = ref
        ->
          Context.update(Data.Schema.UserReferral, ref, %{is_accept: true})
          Data.Context.UserReferrals.check_is_refferal_by_email__clear_cache(ref.referred_to)
          Data.Context.RewardManagers.update_points(ref.referred_from_id, :sign_up_through_referral)
          Map.put(params, "friend_code", params["referral_code"])
          |> Map.put("is_active", true)
          |> Map.put("is_referral", true)
        nil ->
          case Users.get_referral_code_owner(params["referral_code"]) do
            nil ->
              params
              |> Map.put("is_referral", false)
              |> Map.put("is_active", false)
            %{id: id} ->
              Context.create(Data.Schema.UserReferral, %{is_accept: true, referred_to: params["email"],
                referral_code: params["referral_code"], referred_from_id: id})
              Data.Context.UserReferrals.check_is_refferal_by_email__clear_cache(params["email"])

              Data.Context.RewardManagers.update_points(id, :sign_up_through_referral)
              params
              |> Map.put("is_referral", true)
              |> Map.put("is_active", true)
          end
      end
    else
      params
      |> Map.put("is_referral", false)
      |> Map.put("is_active", false)
    end
  end

  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  # create_user_from_request__send_welcome_email
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
  defp create_user_from_request__send_welcome_email(user, params, context, options \\ [])
  defp create_user_from_request__send_welcome_email(user, %{"login_type" => "email"}, context, options), do: JetzyModule.TransactionalEmailModule.welcome_email(user, context, options)
  defp create_user_from_request__send_welcome_email(user, %{"login_type" => _}, context, options), do: {:ok, nil}
  defp create_user_from_request__send_welcome_email(user, _params, context, options), do: JetzyModule.TransactionalEmailModule.welcome_email(user, context, options)

  #----------------------------------------------------------------------------
  # does_user_email_already_exist/1
  #----------------------------------------------------------------------------
  def email_already_exist?(%{"email" => email} = _params) do
    email_exists?(email)
  end
  def email_already_exist?(params), do: params

  #----------------------------------------------------------------------------
  # upload image
  #----------------------------------------------------------------------------
  @doc """
  @deprecated
  """
  def upload_profile_image(params) do
    JetzyModule.AssetStoreModule.upload_if_image_with_thumbnail(params, "image", "user")
    |> default_profile_image()
  end

  #----------------------------------------------------------------------------
  # save_profile_image
  #----------------------------------------------------------------------------
  def save_profile_image(params, context, options \\ []) do
    with {:ok, response} <- JetzyModule.AssetStoreModule.save_image_set(:user_profile, params["image"], context, options) do
      {:ok, response}
      else
      _ -> JetzyModule.AssetStoreModule.select_random_profile_image(context, options)
    end
  end

  #----------------------------------------------------------------------------
  # upload image
  #----------------------------------------------------------------------------
  def upload_profile_image_extended(params) do
    JetzyModule.AssetStoreModule.upload_if_image_extended(params, "image", "user")
    |> default_profile_image_extended()
  end

  #----------------------------------------------------------------------------
  # default_profile_image/1
  #----------------------------------------------------------------------------
  def default_profile_image(user_image) do
    case user_image do
      nil ->
        image = Data.Context.DefaultProfileImages.get_random()
        image && {image.image_name, image.small_image_name}
      _ ->
        user_image
    end
  end

  def default_profile_image_extended(user_image) do
    case user_image do
      nil ->
        image = Data.Context.DefaultProfileImages.get_random()
        image && {image.image_name, image.small_image_name, nil} || {nil, nil, nil}
      _ ->
        user_image
    end
  end

  def local_radius_value() do
    JetzyModule.SearchConfigurationModule.is_local_radius()
  end

  def get_nearby_users(query, %{user_id: current_user_id, lat: lat, long: long, unit: unit, is_friend: is_friend, radius: radius} = params, pagination \\ []) do
    local_radius = local_radius_value()
    follow_status = "followed"
    value = case unit do
      "km" -> 0.621372736649807
      _ -> 1
    end

    radius_value = value * radius

    query = from(q in query)
            |> join(:left, [u], rm in ReportMessage, on: rm.item_id == u.id and rm.is_deleted == false)
      # |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
            |> join(:left, [q], uf in UserFollow, on: uf.followed_id == q.id and uf.follower_id == ^current_user_id and uf.follow_status == ^follow_status)
            |> join(:left, [q], uf2 in UserFollow, on: uf2.follower_id == q.id and uf2.followed_id == ^current_user_id and uf2.follow_status == ^follow_status)
            |> distinct([u, ugl, ...], [asc: fragment("(point(?,?) <@> point(?,?))/?", ugl.longitude, ugl.latitude, ^long, ^lat, ^radius_value), asc: u.id])
            |> order_by([u, ugl], [asc: fragment("(point(?,?) <@> point(?,?))/?", ugl.longitude, ugl.latitude, ^long, ^lat, ^radius_value)])
            |> preload([user_interests: [:interest]])
            |> select([u, ugl, ui, _rm, uf, uf2],
                 %{
                   is_friend: fragment("case when ? is not null or ? is not null then true else false end as is_friend", uf.followed_id, uf2.followed_id),
                   is_local: fragment("case when ? is null then true else (point(?,?) <@> point(?,?))< ? end as is_local",
                     ugl.longitude,
                     ugl.longitude,
                     ugl.latitude,
                     u.longitude,
                     u.latitude,
                     ^local_radius
                   ),
                   distance: fragment(
                     "(point(?,?) <@> point(?,?))/? as distance",
                     ugl.longitude,
                     ugl.latitude,
                     ^long,
                     ^lat,
                     ^radius_value
                   ),
                   distance_unit: ^unit,
                   user: u
                 }
               )
    query = if(is_friend) do
              query
              |> where([_q, _ugl, _ui, _rm, uf, uf2], not is_nil(uf.followed_id) or not is_nil(uf2.followed_id))
            else
              query
            end
            # |> having([_, _, rm], count(rm.id) == 0)
            |> Repo.paginate(pagination)
  end

  def get_nearby_users_guest(query, lat, long, unit, radius, pagination \\ []) do
    local_radius = local_radius_value()
    value = case unit do
      "km" -> 0.621372736649807
      _ -> 1
    end

    radius_value = value * radius

    from(q in query)
    |> join(:left, [u], rm in ReportMessage, on: rm.item_id == u.id and rm.is_deleted == false)
      # |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
    |> order_by([u, ugl], fragment("(point(?,?) <@> point(?,?))", ugl.longitude, ugl.latitude, ^long, ^lat))
    |> preload([user_interests: [:interest]])
    |> select([u, ugl, _ui, _rm, uf, uf2], %{
      is_friend: fragment("false as is_friend"),
      is_local: fragment("case when ? is null then true else (point(?,?) <@> point(?,?))< ? end as is_local",
        ugl.longitude, ugl.longitude, ugl.latitude, u.longitude, u.latitude, ^local_radius),
      distance: fragment("(point(?,?) <@> point(?,?))/? as distance", ugl.longitude, ugl.latitude, ^long, ^lat, ^radius_value),
      distance_unit: ^unit,
      user: u
    })
    |> group_by([u, ugl, _ui, _rm], [u.id, ugl.id])
    |> having([_u, _ugl, _ui, rm], count(rm.id) == 0)
    |> Repo.paginate(pagination)
  end

  def email_exists?(nil), do: false
  def email_exists?(email) do
    query = from(u in User, where: u.email == ^email)
    Repo.exists?(query)
  end

  def is_social_login_user(email) do
    query =
      from(u in User,
        where: not is_nil(u.social_id) and u.email == ^email
      )
    Repo.exists?(query)
  end
  def paginate_users_for_group_chat(params, page_size \\ 10)
  def paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: _lat, long: _long, page: page, room_id: room_id} = params, page_size) do
    follow_status = "followed"

    # if we have search parameter then add a where clause for it. otherwise initiate query without search
    if(Map.has_key?(params, :search)) do
      #      search =
      User |> UsersSearch.run("%#{params.search}%")
      # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
    else
      User
    end
    |> select(
         [u, uf, uf2, ru],
         %{
           id: u.id,
           first_name: u.first_name,
           last_name: u.last_name,
           email: u.email,
           gender: u.gender,
           dob: u.dob,
           is_deactivated: u.is_deactivated,
           home_town_city: u.home_town_city,
           image_name: u.image_name,
           small_image_name: u.small_image_name,
           is_active: u.is_active,
           influencer_level: u.influencer_level,
           user_level: u.user_level,
           #  is_friend: fragment("? as isf", false),
           #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
           is_group_member: fragment("CASE when ? is not null then true else false end", ru.id),
           followership: fragment(
             "case when ? is not null then 'A' when ? is not null then 'B' else 'Z' end as f",
             uf.followed_id,
             uf2.followed_id
           )
         }
       )
    |> join(:left, [u], uf in UserFollow, on: uf.follower_id == u.id and uf.followed_id == ^current_user_id and uf.follow_status == ^follow_status)
    |> join(:left, [u], uf2 in UserFollow, on: uf2.followed_id == u.id and uf2.follower_id == ^current_user_id and uf2.follow_status == ^follow_status)
    |> join(:left, [u, uf, uf2], ru in Data.Schema.RoomUser, on: u.id == ru.user_id and ru.room_id == ^room_id)
    |> where([u], u.id != ^current_user_id)
    |> where([u], u.effective_status == :active)
    |> where([u], fragment("? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)", u.id, ^UUID.string_to_binary!(current_user_id)))
    |> order_by([u], [asc: fragment("f"),
    # desc: fragment("rank"),
     asc: u.first_name, asc: u.last_name])
#    |> distinct([u], u.id)
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: _lat, long: _long, page: page} = params, page_size) do
    follow_status = "followed"

    # if we have search parameter then add a where clause for it. otherwise initiate query without search
    if(Map.has_key?(params, :search)) do
      #      search =
      User |> UsersSearch.run("%#{params.search}%")
      # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
    else
      User
    end
    |> select(
         [u, uf, uf2],
         %{
           id: u.id,
           first_name: u.first_name,
           last_name: u.last_name,
           email: u.email,
           gender: u.gender,
           dob: u.dob,
           is_deactivated: u.is_deactivated,
           home_town_city: u.home_town_city,
           image_name: u.image_name,
           small_image_name: u.small_image_name,
           is_active: u.is_active,
          #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
           is_group_member: false,
           followership: fragment(
             "case when ? is not null then 'A' when ? is not null then 'B' else 'Z' end as f",
             uf.followed_id,
             uf2.followed_id
           )
         }
       )

    |> join(:left, [u], uf in UserFollow, on: uf.follower_id == u.id and uf.followed_id == ^current_user_id and uf.follow_status == ^follow_status)
    |> join(:left, [u], uf2 in UserFollow, on: uf2.followed_id == u.id and uf2.follower_id == ^current_user_id and uf2.follow_status == ^follow_status)
    |> where([u], u.id != ^current_user_id)
      #User's having null or empty first or last name would be expelled from the list
    |> where([u], u.effective_status == :active)
    |> where([u], fragment("? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)", u.id, ^UUID.string_to_binary!(current_user_id)))
    |> order_by([u], [asc: fragment("f"),
    # desc: fragment("rank"),
     desc: u.inserted_at])
    #    |> distinct([u], u.id)
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def paginate_user_following(%{page: page} = params, current_user_id, page_size \\ 10) do
    follow_status = "followed"
    if(Map.has_key?(params, :search)) do
      #      search =
      User |> UsersSearch.run("%#{params.search}%")
      # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
    else
      User
    end
    |> join(:inner, [u], uf in UserFollow, on: u.id == uf.followed_id and uf.follower_id == ^current_user_id and uf.follow_status == ^follow_status)
    |> where([u], u.id != ^current_user_id)
      #User's having null or empty first or last name would be expelled from the list
    |> where([u], u.effective_status == :active)
    |> where([u], fragment("? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)",
      u.id, ^UUID.string_to_binary!(current_user_id)))
    |> order_by([u], [asc: u.first_name, asc: u.last_name])
    |> select([u], %{
      id: u.id,
      first_name: u.first_name,
      last_name: u.last_name,
      email: u.email,
      gender: u.gender,
      dob: u.dob,
      influencer_level: u.influencer_level,
      user_level: u.user_level,
      is_deactivated: u.is_deactivated,
      home_town_city: u.home_town_city,
      image_name: u.image_name,
      small_image_name: u.small_image_name,
      is_active: u.is_active,
      #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
      is_group_member: false
    })
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def paginate_user_followers(%{page: page} = params, current_user_id, page_size \\ 10) do
    if(Map.has_key?(params, :search)) do
      #      search =
      User |> UsersSearch.run("%#{params.search}%")
      # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
    else
      User
    end
    |> join(:inner, [u], uf in UserFollow, on: u.id == uf.follower_id and uf.followed_id == ^current_user_id and uf.follow_status == :followed)
    |> where([u], u.id != ^current_user_id)
      #User's having null or empty first or last name would be expelled from the list
    |> where([u], u.effective_status == :active)
    |> where([u], fragment("? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)",
      u.id, ^UUID.string_to_binary!(current_user_id)))
    |> order_by([u], [asc: u.first_name, asc: u.last_name])
    |> select([u], %{
      id: u.id,
      first_name: u.first_name,
      last_name: u.last_name,
      email: u.email,
      gender: u.gender,
      dob: u.dob,
      influencer_level: u.influencer_level,
      user_level: u.user_level,
      is_deactivated: u.is_deactivated,
      home_town_city: u.home_town_city,
      image_name: u.image_name,
      small_image_name: u.small_image_name,
      is_active: u.is_active,
      #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
      is_group_member: false
    })
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def paginate_users_with_similar_interests(%{page: page} = params, current_user_id, page_size \\ 10) do
    user_query =
      if(Map.has_key?(params, :search)) do
        #      search =
        User |> UsersSearch.run("%#{params.search}%")
        # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
      else
        User
      end
      |> join(:inner, [u], uf in UserFollow, on: (uf.followed_id == u.id and uf.follower_id != ^current_user_id) or (uf.follower_id == u.id and uf.followed_id != ^current_user_id) and u.id != ^current_user_id)
      |> where([u, _], u.effective_status == :active and u.id != ^current_user_id)
      |> distinct([u, _], u.id)
      |> limit(5)
      |> select([u], %{
        id: u.id,
        first_name: u.first_name,
        last_name: u.last_name,
        email: u.email,
        gender: u.gender,
        dob: u.dob,
        is_deactivated: u.is_deactivated,
        home_town_city: u.home_town_city,
        image_name: u.image_name,
        small_image_name: u.small_image_name,
        is_active: u.is_active,
        #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
        is_group_member: false
      })

    interests =
      Interest
      |> join(:inner, [i], ui in UserInterest, on: ui.interest_id == i.id and ui.user_id == ^current_user_id)
      |> where([i, ui], fragment("select count(user_id) from user_interests where interest_id = ?", ui.interest_id) > 1)
      |> Repo.paginate([page: page, page_size: page_size])

    result = Enum.reduce(interests.entries, [], fn interest, acc ->
      acc ++ [interest |> Repo.preload(user_interests: user_query)]
    end)

    Map.put(interests, :entries, result)
  end

  def paginate_users_by_interest_id(%{page: page, interest_id: interest_id} = params, current_user_id, page_size \\ 10) do
    user_query =
      if(Map.has_key?(params, :search)) do
        #      search =
        User |> UsersSearch.run("%#{params.search}%")
        # where(User, [u], ilike(u.first_name, ^"%#{params.search}%") or ilike(u.last_name, ^"%#{params.search}%"))
      else
        User
      end
      |> join(:inner, [u], ui in UserInterest, on: ui.user_id == u.id and ui.interest_id == ^interest_id)
      |> join(:inner, [u, _], uf in UserFollow, on: (uf.followed_id == u.id and uf.follower_id != ^current_user_id) or (uf.follower_id == u.id and uf.followed_id != ^current_user_id) and u.id != ^current_user_id)
      |> where([u, _, _], u.effective_status == :active and u.id != ^current_user_id)
      |> distinct([u, _, _], u.id)
      |> select([u], %{
        id: u.id,
        first_name: u.first_name,
        last_name: u.last_name,
        email: u.email,
        gender: u.gender,
        dob: u.dob,
        influencer_level: u.influencer_level,
        user_level: u.user_level,
        is_deactivated: u.is_deactivated,
        home_town_city: u.home_town_city,
        image_name: u.image_name,
        small_image_name: u.small_image_name,
        is_active: u.is_active,
        #  rank: ^(if Map.has_key?(params, :search), do: fragment("to_ts_query(11)*100 as rank", UsersSearch.prefix_search(User, "%#{params.search}%")), else: fragment("1 as rank")),
        is_group_member: false
      })
      |> Repo.paginate([page: page, page_size: page_size])

  end

  @doc """
  @todo we need a rate limit on login attempts. @pri-0
  """
  def login_by_email_and_pass(email, pass, options \\ nil) do
    case get_user_by_email(email) do
      %User{} = user -> check_password(user, pass, options)
      nil -> nil
      _ -> {:error, :unauthorized}
    end
  end

  def login_without_password(user_id) do
    case Context.get(User, user_id) do
      %User{} = user ->
        {:ok, user, Guardian.encode_and_sign(user, %{}, ttl: {24, :weeks}) |> elem(1)}
      nil -> nil
      _ -> {:error, :unauthorized}
    end
  end


  def get_user_by_email(email) do
    Context.get_by(User, email: email)
  end

  def get_user_role(user_id) do
    from(ur in UserRole,
    where: ur.user_id == ^user_id,
    select: ur.role_id)
    |> Repo.one()
  end

  def get_users_by_active_status(is_active, page, page_size \\ 10) do
    from(u in User,
    where: u.is_active == ^is_active)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def check_password(user, pass, options \\ nil) do
    password_matched =
      try do
        verify_pass(pass, user.password)
      rescue
        _ -> false
      end
      
    case password_matched do
      true ->
        ttl = options[:ttl] || {24, :weeks}
        {:ok, user, Guardian.encode_and_sign(user, %{}, ttl: ttl) |> elem(1)}

      false ->
        {:error, :unauthorized}
    end
  end


  def get_interest_users_sort_by_location_and_friends(%{interest_id: interest_id, user_id: user_id, lat: lat, long: long, page: page}, page_size \\ 10) do

    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)
    User
    |> join(:inner, [u], ui in  UserInterest, on: u.id == ui.user_id ) # Get that one specific Interest
    |> join(:left, [_, ui], uf in Data.Schema.UserFriend, on: uf.friend_id == ui.user_id and uf.user_id == ^user_id) # Look for friends with same interest
    |> where([_, ui, _], ui.interest_id == ^interest_id)
    |> where([u, _, _], u.id not in ^blocked_user_ids)
    |> where([u, _, _], u.effective_status == :active)
    |> where([u, _, _], u.id != ^user_id)
    |> order_by([_, _, uf], [is_nil(uf.id)])
    |> order_by([u, _, _], fragment(
#          "ST_DISTANCE(ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography)",
           "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
           u.longitude, u.latitude, ^long, ^lat
         )
       )
#    |> join(:inner, [u, _, uf], ub in UserBlock, on: uf.friend_id != ub.user_to_id or u.id != ub.user_to_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> Tanbits.Shim.inject_uir()
  end

  def update(user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_for_social(user, attrs \\ %{}) do
    user
    |> User.changeset_for_social(attrs)
    |> Repo.update()
  end

  def update_user_is_active(user, attrs \\ %{}) do
    user
    |> User.changeset_for_is_active(attrs)
    |> Repo.update()
  end

  def validate_referral_code(referral_code, :ignore_case) do
    res = User
          |> where([u], u.referral_code == ^referral_code)
          |> where([u], u.is_deactivated == false)
          |> Repo.exists?()
    if !res do
      lrc = String.downcase(referral_code)
      res = User
            |> where([u], fragment("lower(?)", u.referral_code) == type(^lrc, :string))
            |> where([u], u.is_deactivated == false)
            |> Repo.exists?()
      if !res do
        UserReferralCodeLog
        |> where([q], q.referral_code == ^referral_code)
        |> join(:inner, [q], u in User, on: u.id == q.user_id)
        |> where([_, u], u.is_deactivated == false)
        |> Repo.exists?()
        if !res do
          UserReferralCodeLog
          |> where([q], fragment("lower(?)", q.referral_code) == type(^lrc, :string))
          |> join(:inner, [q], u in User, on: u.id == q.user_id)
          |> where([_, u], u.is_deactivated == false)
          |> Repo.exists?()
        else
          res
        end
      else
        res
      end
    else
      res
    end
  end


  def validate_referral_code(referral_code) do
    res = User
          |> where([u], u.referral_code == ^referral_code)
          |> where([u], u.is_deactivated == false)
          |> Repo.exists?()
    if !res do
      UserReferralCodeLog
      |> where([q], q.referral_code == ^referral_code)
      |> join(:inner, [q], u in User, on: u.id == q.user_id)
      |> where([_, u], u.is_deactivated == false)
      |> Repo.exists?()
    else
      res
    end
  end


  @doc """
   @todo we should be building and querying from user_point_balances.
  """
  def point_balance(user_id) do
    # Todo query redis,
    # On miss check point_balance
    # On miss rebuild.
    rebuild_point_tally(user_id)
  end

  def rebuild_point_tally(user_id) do
    query = from u in Data.Schema.UserRewardTransaction,
                 where: u.user_id == ^user_id,
                 where: u.is_canceled == false,
                 select: sum(u.point)
    p = Data.Repo.one(query) || 0
    query = from u in Data.Schema.UserOfferTransaction,
                 where: u.user_id == ^user_id,
                 where: u.is_canceled == false,
                 select: sum(u.point)
    p2 = Data.Repo.one(query) || 0
    points = round(p - p2)
    %{user: user_id, points: points}
  end
  
  
  
  def get_referral_code_owner(referral_code, :ignore_case) do
    res = User
          |> where([u], u.referral_code == ^referral_code)
          |> select([u], %{id: u.id})
          |> Repo.one()
    if is_nil(res) do
      lrc = String.downcase(referral_code)
      res = User
            |> where([u], fragment("lower(?)", u.referral_code) == type(^lrc, :string))
            |> select([u], %{id: u.id})
            |> Repo.one()
      if is_nil(res) do
        UserReferralCodeLog
        |> where([q], q.referral_code == ^referral_code)
        |> select([q], %{id: q.user_id})
        |> Repo.one()
        if is_nil(res) do
          UserReferralCodeLog
          |> where([q], fragment("lower(?)", q.referral_code) == type(^lrc, :string))
          |> select([q], %{id: q.user_id})
          |> Repo.one()
        else
          res
        end
      else
        res
      end
    else
      res
    end
  end

  def get_referral_code_owner(referral_code) do
    UserReferrals.get_referral_code_owner(referral_code)
  end

  def get_all_users_by_email(emails) do
    User
    |> join(:left, [u], usa in UserSocialAccount, on: u.id == usa.user_id)
    |> where([u, _], u.email in(^emails))
    |> or_where([_, usa], usa.external_id in(^emails))
    |> select([u, usa],
         %{email: fragment("CASE WHEN ? IS NULL THEN ?
                             ELSE ?
                   end", u.email, usa.external_id, u.email),
      first_name: u.first_name, last_name: u.last_name, image_name: u.image_name, user_id: u.id})
    |> Repo.all()
  end

  def get_all_users_by_contact_email(emails, existing_user_ids) do
    Repo.all(
      from u in User,
      join: c in assoc(u, :user_contacts), on: u.id == c.user_id,
      where: u.email in ^emails and u.id not in ^existing_user_ids
    )
  end

  def create_user_contacts(contacts, user_id) do
    Enum.map(contacts, fn c ->
      user_contact = Map.merge(c, %{user_id: user_id})

      %UserContact{}
      |> UserContact.changeset(user_contact)
      |> Repo.insert()
    end)
  end

   def delete_user_roles(user_id)do
    from(ur in UserRole,
      where: ur.user_id == ^user_id)
    |> Repo.delete_all
  end

  def filter_user_ids(user_ids) do
    User
    |> where([u], u.id in ^user_ids)
    |> select([u], u.id)
    |> Repo.all
  end

  def create_geo_loc_and_geo_loc_log(%{"user_latitude" => latitude, "user_longitude" => longitude} = params,  user_id) do
    Context.create(UserGeoLocationLog, %{latitude: latitude, longitude: longitude, user_id: user_id, is_actual_location: true})
    case Context.get_by(UserGeoLocation, %{user_id: user_id})do
      nil -> Context.create(UserGeoLocation, %{latitude: latitude, longitude: longitude, user_id: user_id, is_actual_location: true})
      user -> Context.update(UserGeoLocation, user, %{latitude: latitude, longitude: longitude})
    end
  end

  def create_geo_loc_and_geo_loc_log(params, user_id) do
  params
  end

  def get_influencers_ids(count) do
    User
    |> where([u], u.influencer_level in [:basic, :standard, :celebrity])
    |> where([u], u.effective_status == ^:active)
    |> order_by(fragment("RANDOM()"))
    |> limit(^count)
    |> select([u], u.id)
    |> Repo.all()
  end

  def forget_user(nil),do: :do_nothing

  def forget_user(%User{} = user)do
    message_ids = RoomMessages.get_user_messages_by_user_id(user.id)
    event_ids = UserEvents.get_user_events_ids_by_user_id(user.id)
    new()
    |> run(:update_events, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserEvent, user.id])
    |> run(:update_event_images, UserEvents, :delete_event_images, [event_ids])
    |> run(:update_settings, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserSetting, user.id])
    |> run(:update_reward_transactions, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserRewardTransaction, user.id])
    |> run(:update_reports, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserReport, user.id])
    |> run(:update_profile_images, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserProfileImage, user.id])
    |> run(:update_user_interests, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserInterest, user.id])
    |> run(:update_images, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserImage, user.id])
    |> run(:update_locations, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserGeoLocation, user.id])
    |> run(:update_location_logs, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserGeoLocationLog, user.id])
    |> run(:update_filters, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserFilter, user.id])
    |> run(:update_favorites, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserFavorite, user.id])
    |> run(:update_event_likes, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserEventLike, user.id])
    |> run(:update_emergency_contacts, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserEmergencyContact, user.id])
    |> run(:update_countries, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.UserCountry, user.id])
    |> run(:update_restaurants, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.Restaurant, user.id])
    |> run(:update_report_message, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.ReportMessage, user.id])
    |> run(:update_notification_settings, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.NotificationSetting, user.id])
    |> run(:update_like_details, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.LikeDetail, user.id])
    |> run(:update_invite_friend_requests, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.InviteFriendRequest, user.id])
    |> run(:update_had_cdns, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.HadCdnUser, user.id])
    |> run(:update_comments, Data.Context, :soft_delete_records_by_user_id, [Data.Schema.Comment, user.id])
    |> run(:update_groups, __MODULE__, :handle_groups, [user])
    |> run(:update_message_metas, RoomMessageMetas, :soft_delete_messages_by_message_ids, [message_ids])
    |> run(:update_messages, RoomMessages, :delete_user_messages, [user.id])
    |> run(:update_follow_followings, UserFollows, :delete_follow_following_record_by_user_id, [user.id])
    |> run(:update_blocks, UserBlocks, :delete_block_records_by_user_id, [user.id])
    |> run(:update_push_notification_logs, PushNotificationLogs, :delete_push_notification_logs_by_user_id, [user.id])
    |> run(:update_notifications_records, NotificationsRecords, :delete_notification_records_by_user_id, [user.id])
    |> run(:update_interests, Interests, :delete_interest_by_user_id, [user.id])
    |> run(:update_interest_topics, InterestTopics, :delete_interest_topic_by_user_id, [user.id])
    |> Repo.transaction()
    |> case do
         {:error, event, %Ecto.QueryError{message: error}, _} = result ->
           Context.create(Data.Schema.UserDeletionLog, %{event: to_string(event), error: error, deleted_user_id: user.id, status: :not_completed})
           {:error, result}
         _ ->
           Context.create(Data.Schema.UserDeletionLog, %{deleted_user_id: user.id, status: :completed})
           :ok
       end
  end

  def forget_user(user_id) when is_binary(user_id) do
    user = Context.get(User, user_id)
    forget_user(user)
  end

  def handle_groups(_, _ , user) do
    #in case if user is admin of some groups
    rooms = Rooms.get_user_groups(user.id)
    try do
      Enum.each(rooms, fn room_id ->
        # check if user is alone in the room then we do not need to do anything
        if !RoomUsers.room_user_exists?(room_id) do
          :do_nothing
        else
          #There are users in the room, so get the older one and make him/her admin of the group
          if !RoomUsers.check_admin_exists?(room_id, user.id) do
            old_room_user = RoomUsers.get_oldest_room_user(room_id)
            Context.update(RoomUser, old_room_user, %{user_role: "admin"})
          end
        end
      end)
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end

end
