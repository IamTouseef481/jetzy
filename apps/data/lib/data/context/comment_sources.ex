defmodule Data.Context.CommentSources do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.CommentSource

  @spec preload_all(CommentSource.t()) :: CommentSource.t()
  def preload_all(data), do: Repo.preload(data, [])

end
