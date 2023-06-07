defmodule Data.Context.AddressComponents do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.AddressComponent

  @spec preload_all(AddressComponent.t()) :: AddressComponent.t()
  def preload_all(data), do: Repo.preload(data, [])

end
