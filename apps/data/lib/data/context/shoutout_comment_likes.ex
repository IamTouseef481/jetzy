defmodule Data.Context.ShoutCommentLikes do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.ShoutCommentLike

  def get_like_by_comment_and_user_id(comment_id, user_id) do
    ShoutCommentLike
    |> where([scl], scl.comment_id == ^comment_id)
    |> where([scl], scl.user_id == ^user_id)
    |> Repo.one()
  end

  def is_self_liked?(user_id, comment_id) do
    from(scl in ShoutCommentLike, where: scl.comment_id == ^comment_id and scl.user_id == ^user_id)
    |> Repo.exists?()
  end


end
