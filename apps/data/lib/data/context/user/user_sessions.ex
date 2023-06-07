defmodule Data.Context.UserSessions do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserSession

  @spec preload_all(UserSession.t()) :: UserSession.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
