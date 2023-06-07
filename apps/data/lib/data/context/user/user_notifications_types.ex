defmodule Data.Context.UserNotificationsTypes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserNotificationsType

  @spec preload_all(UserNotificationsType.t()) :: UserNotificationsType.t()
  def preload_all(data), do: Repo.preload(data, [])

end
