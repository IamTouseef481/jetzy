defmodule Data.Context.UserEventCommentLikes do
  import Ecto.Query, warn: false
  alias Data.Repo

  alias Data.Schema.UserEventCommentLike

  @spec preload_all(UserEventCommentLike.t()) :: UserEventCommentLike.t()
  def preload_all(data), do: Repo.preload(data, [:user_event_comment, :user])

  def get_comment_likes_count(comment_id) do
    UserEventCommentLike
    |> where([ld], ld.room_message_id == ^comment_id)
    |> select([ld], count(ld.id))
    |> Repo.one()
  end

  def liked?(user_id, source_id) do
    from(likes in UserEventCommentLike,
    where: (likes.comment_id == ^source_id or likes.reply_id == ^source_id) and (likes.liked_by_id == ^user_id))
    |> Repo.exists?()
  end

  def is_self_liked?(user_id, comment_id) do
    from(scl in UserEventCommentLike, where: scl.room_message_id == ^comment_id and scl.liked_by_id == ^user_id)
    |> Repo.exists?()
  end

end
