defmodule Data.Context.UserCountries do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserCountry

  @spec preload_all(UserCountry.t()) :: UserCountry.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

  def get_by_user_id(user_id) do
    UserCountry
    |> where([uc], uc.user_id == ^user_id)
    |> Repo.all()
  end

end
