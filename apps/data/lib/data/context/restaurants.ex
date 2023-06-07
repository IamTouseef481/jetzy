defmodule Data.Context.Restaurants do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.Restaurant

  @spec preload_all(Restaurant.t()) :: Restaurant.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
