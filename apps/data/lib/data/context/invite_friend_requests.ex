defmodule Data.Context.InviteFriendRequests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.InviteFriendRequest

  @spec preload_all(InviteFriendRequest.t()) :: InviteFriendRequest.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
