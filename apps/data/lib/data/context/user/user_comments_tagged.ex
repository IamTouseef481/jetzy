defmodule Data.Context.UserCommentTaggeds do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserCommentTagged

  @spec preload_all(UserCommentTagged.t()) :: UserCommentTagged.t()
  def preload_all(data), do: Repo.preload(data, [:comment_source, ])

end
