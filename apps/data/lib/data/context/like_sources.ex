defmodule Data.Context.LikeSources do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.LikeSource

  @spec preload_all(LikeSource.t()) :: LikeSource.t()
  def preload_all(data), do: Repo.preload(data, [])

end
