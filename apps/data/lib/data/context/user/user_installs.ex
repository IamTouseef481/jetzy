defmodule Data.Context.UserInstalls do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.UserInstall

  def get_user_installs_by_device_token(device_token) do
    UserInstall
    |> where([ui], ui.device_token == ^device_token)
    |> Repo.one()
  end

  def get_fcm_token_by_user_id(user_id) do
    UserInstall
    |> where([ui], ui.user_id == ^user_id)
    |> select([ui], ui.fcm_token)
    |> Repo.all()
  end

  def get_device_type_and_last_login__cache_key(user_id) do
    {:get_device_type_and_last_login, user_id}
  end
  
  def get_device_type_and_last_login__clear_cache(user_id) do
    key = get_device_type_and_last_login__cache_key(user_id)
    ConCache.delete(ConCache.Resident, key)
  end
  
  def get_device_type_and_last_login__cached(user_id) do
    key = get_device_type_and_last_login__cache_key(user_id)
    ConCache.get_or_store(ConCache.Resident, key, fn() ->
      i = UserInstall
          |> where([ui], ui.user_id == ^user_id)
          |> order_by([ui], ui.inserted_at)
          |> limit(1)
          |> select([ui], %{device_type: ui.os, last_login: ui.inserted_at})
          |> Repo.one
      {:ok, i}
    end) |> case do
                  {:ok, v} -> v
                  _ -> nil
            end
  end
  
  def get_device_type_and_last_login(user_id) do
    UserInstall
    |> where([ui], ui.user_id == ^user_id)
    |> order_by([ui], ui.inserted_at)
    |> limit(1)
    |> select([ui], %{device_type: ui.os, last_login: ui.inserted_at})
    |> Repo.one
  end

  def get_saved_user(user_id) do
    UserInstall
    |> where([ui], ui.user_id == ^user_id)
    |> select([ui], ui.current_jwt)
    |> Repo.all()
  end

  def get_user_installs_by_jwt(user_id, current_jwt) do
    UserInstall
    |> where([ui], ui.user_id == ^user_id and ui.current_jwt == ^current_jwt)
    # |> select([ui], ui.current_jwt)
    |> limit(1)
    |> Repo.one
  end


end
