defmodule Data.Context.UserShoutoutsTaggeds do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserShoutoutsTagged

  @spec preload_all(UserShoutoutsTagged.t()) :: UserShoutoutsTagged.t()
  def preload_all(data), do: Repo.preload(data, [:shoutout, ])

end
