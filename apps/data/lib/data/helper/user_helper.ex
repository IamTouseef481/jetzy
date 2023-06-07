defmodule Data.Helper.UserHelper do
  @moduledoc false

#  alias Data.SQL.Repo
  alias Data.Repo, as: MyRepo
#  alias Data.Schema.{UserRole, User}
#  import Ecto.Query
  import Mix.Generator, only: [create_file: 2]
#  import Macro, only: [underscore: 1]
#  import Bcrypt, only: [hash_pwd_salt: 1]

  def run() do
    table = "users"
    order_by = "first_name"
    case create_csv_file(table) do
      true ->
        {:ok, opened_file} = File.open("apps/data/priv/repo/seeds/#{table}.csv", [:append])
        fields = "id,first_name,last_name,email,gender,dob,password,is_deactivated,is_show_on_profile,is_push_notification,is_enable_chat,is_groupchat_enable,is_moments_enable,home_town_city,home_town_country,user_about,login_type,panic_message,quick_blox_id,social_id,is_email_verified,is_info,current_city,current_country,image_name,quick_blox_password,referral_code,is_referral,friend_code,is_deleted,user_inivite_type,un_subscribe,user_role,is_profile_image_sync,dob_full,school,employer,latitude,longitude,is_active,deleted_at,inserted_at,updated_at,current_jwt,age,language,is_selfie_verified,user_verification_image,verification_token"
#        fields = "id,interest_name,description,status,background_colour,image_name,is_private,small_image_name,is_deleted,is_group_private,deleted_at,inserted_at,updated_at"
        IO.binwrite(opened_file, ~s(#{fields}\n))
        File.close(opened_file)
        get_data(table, fields, order_by)
      _ -> {:error, "Unable To Create #{table} File"}
    end
    table = "user_roles"
    order_by = "role_id"
        case create_csv_file(table) do
          true ->
    {:ok, opened_file} = File.open("apps/data/priv/repo/seeds/#{table}.csv", [:append])
    fields = "id,role_id,user_id,inserted_at,updated_at"
    IO.binwrite(opened_file, ~s(#{fields}\n))
    File.close(opened_file)
    get_data(table, fields, order_by)
          _ -> {:error, "Unable To Create USERS File"}
        end
  end
  defp get_data(table, fields, order_by, skip \\ 0, next \\ 10000) do
    case Ecto.Adapters.SQL.query(MyRepo,
      "SELECT #{fields} FROM #{table} ORDER BY #{order_by} limit #{next} OFFSET #{skip}"
    ) do
      {:error, %Postgrex.Error{} = error} -> {:error, error}
      {:ok, %Postgrex.Result{rows: rows}} ->
        if Enum.count(rows) > 0 do
          write_data_to_csv_file(table, rows)
          get_data(table, fields, order_by, skip + next)
        end
    end
  end
  defp create_csv_file(file_name) do
    create_file("apps/data/priv/repo/seeds/#{file_name}.csv", "")
  end
  defp write_data_to_csv_file(table, data) do
    {:ok, opened_file} = File.open("apps/data/priv/repo/seeds/#{table}.csv", [:append])

    _list = Enum.reduce(data, %{}, fn list, _map ->

      stringified =
        map_fields(list, table)
        |> Enum.map(fn x ->
          if is_bitstring(x) do
            if String.length(x) > 0, do: "\"#{String.replace(x, :binary.compile_pattern("\""), "'")}\"", else: x else x
          end
        end)
        |> Enum.join(",")
        |> process_escape_characters()
       IO.binwrite(opened_file, ~s(#{stringified}\n))
    end)
      File.close(opened_file)
  end
  defp map_fields(list, table) do
    case table do
      "user_roles" ->
        {id, _} = List.pop_at(list, 0)
        {user_id, _} = List.pop_at(list, 2)
        list
        |> List.replace_at(0, process_uuid(id))
        |> List.replace_at(2, process_uuid(user_id))
      "users" ->
        {id, _} = List.pop_at(list, 0)
        list
        |> List.replace_at(0, process_uuid(id))
      "interests" ->
        {id, _} = List.pop_at(list, 0)
        list
        |> List.replace_at(0, process_uuid(id))
      _ -> list
    end
  end
  defp is_binary!(binary) do
    case UUID.info(binary) do
      {:error, _} -> false
      {:ok, _} -> true
    end
  end
  defp process_uuid(id) do
    if is_binary!(id) do
      case Tds.Ecto.UUID.cast(id) do
        :error -> "error"
        {:ok, _idd} ->
          UUID.binary_to_string!(id)
      end
    else
      id
    end
  end

  # @todo remove after may 2022
  #  defp convert_and_update_uuids(list, value, index) do
  #    case Tds.Ecto.UUID.cast(value) do
  #      :error -> List.replace_at(list, index, "") #value) if invalid uuid, it must be empty
  #      {:ok, value} -> List.replace_at(list, index, value)
  #    end
  #  end
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

  # @todo remove after may 2022
  #  defp translate_binaries(uuid) do
  #    case Tds.Ecto.UUID.cast(uuid) do
  #      :error -> :error
  #      {:ok, value} -> value
  #    end
  #  end
end
#id,interest_name,description,status,background_colour,image_name,is_private,small_image_name,is_deleted,is_group_private,deleted_at,inserted_at,updated_at
#id,first_name,last_name,email,gender,dob,password,is_deactivated,is_show_on_profile,is_push_notification,is_enable_chat,is_groupchat_enable,is_moments_enable,home_town_city,home_town_country,user_about,login_type,panic_message,quick_blox_id,social_id,is_email_verified,is_info,current_city,current_country,image_name,quick_blox_password,referral_code,is_referral,friend_code,is_deleted,user_inivite_type,un_subscribe,user_role,is_profile_image_sync,dob_full,school,employer,latitude,longitude,is_active,deleted_at,inserted_at,updated_at,current_jwt,age,language,is_selfie_verified,user_verification_image,verification_token
