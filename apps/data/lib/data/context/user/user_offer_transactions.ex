defmodule Data.Context.UserOfferTransactions do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserOfferTransaction

  @spec preload_all(UserOfferTransaction.t()) :: UserOfferTransaction.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
