defmodule Data.Context.UserShoutoutInterests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserShoutoutInterest

  @spec preload_all(UserShoutoutInterest.t()) :: UserShoutoutInterest.t()
  def preload_all(data), do: Repo.preload(data, [:shoutout, :user, :interest, ])

end
