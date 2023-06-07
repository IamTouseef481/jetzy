defmodule Data.Context.UserPushTokens do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPushToken

  @spec preload_all(UserPushToken.t()) :: UserPushToken.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
