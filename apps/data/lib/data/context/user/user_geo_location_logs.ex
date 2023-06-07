defmodule Data.Context.UserGeoLocationLogs do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserGeoLocationLog

  @spec preload_all(UserGeoLocationLog.t()) :: UserGeoLocationLog.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
