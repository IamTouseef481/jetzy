defmodule Data.Context.UserMoments do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserMoment

  @spec preload_all(UserMoment.t()) :: UserMoment.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
