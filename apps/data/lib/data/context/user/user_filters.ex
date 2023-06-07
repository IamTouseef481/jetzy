defmodule Data.Context.UserFilters do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserFilter

  @spec preload_all(UserFilter.t()) :: UserFilter.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
