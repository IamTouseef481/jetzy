defmodule Data.Context.UserShoutoutsPrivates do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserShoutoutsPrivate

  @spec preload_all(UserShoutoutsPrivate.t()) :: UserShoutoutsPrivate.t()
  def preload_all(data), do: Repo.preload(data, [:shoutout, ])

end
