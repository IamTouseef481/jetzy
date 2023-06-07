defmodule Data.Context.UserMomentLikes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserMomentLike

  @spec preload_all(UserMomentLike.t()) :: UserMomentLike.t()
  def preload_all(data), do: Repo.preload(data, [:user, :moment, ])

end
