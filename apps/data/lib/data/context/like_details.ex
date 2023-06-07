defmodule Data.Context.LikeDetails do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.LikeDetail

  @spec preload_all(LikeDetail.t()) :: LikeDetail.t()
  def preload_all(data), do: Repo.preload(data, [:like_source, :user])

  def get_like_by_post_and_user_id(post_id, user_id) do
    LikeDetail
    |> where([ld], ld.item_id == ^post_id)
    |> where([ld], ld.user_id == ^user_id)
    |> Repo.one()
  end

  def is_self_liked?(user_id, post_id) do
    from(ld in LikeDetail, where: ld.item_id == ^post_id and ld.user_id == ^user_id)
    |> Repo.exists?()
  end

  def get_likes_count_by_item_id(item_id) do
    LikeDetail
    |> where([ld], ld.item_id == ^item_id)
    |> where([ld], ld.liked == true)
    |> select([ld], count(ld.id))
    |> Repo.one()
  end
end
