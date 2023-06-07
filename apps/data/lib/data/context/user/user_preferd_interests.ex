defmodule Data.Context.UserPreferedInterests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPreferedInterest

  @spec preload_all(UserPreferedInterest.t()) :: UserPreferedInterest.t()
  def preload_all(data), do: Repo.preload(data, [:user, :interest, ])

end
