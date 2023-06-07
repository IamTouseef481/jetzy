defmodule Data.Context.UserPointBalances do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPointBalance

  @spec preload_all(UserPointBalance.t()) :: UserPointBalance.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
