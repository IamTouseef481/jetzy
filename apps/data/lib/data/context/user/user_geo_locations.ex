defmodule Data.Context.UserGeoLocations do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserGeoLocation

  @spec preload_all(UserGeoLocation.t()) :: UserGeoLocation.t()
  def preload_all(data), do: Repo.preload(data, [:user, :city_lat_log, ])

end
