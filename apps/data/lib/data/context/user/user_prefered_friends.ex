defmodule Data.Context.UserPreferedFriends do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPreferedFriend

  @spec preload_all(UserPreferedFriend.t()) :: UserPreferedFriend.t()
  def preload_all(data), do: Repo.preload(data, [:user, :friend, ])

end
