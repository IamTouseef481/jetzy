defmodule Data.Context.UserPreferences do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPreference

  @spec preload_all(UserPreference.t()) :: UserPreference.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

  def get_by_user_id(user_id) do
    query = from(up in UserPreference,
            where: up.user_id == ^user_id,
            select: up.preference_type)
    Repo.one(query)

  end

end
