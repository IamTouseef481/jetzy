defmodule Data.Context.CityLatLongs do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.CityLatLong

  @spec preload_all(CityLatLong.t()) :: CityLatLong.t()
  def preload_all(data), do: Repo.preload(data, [])

end
