defmodule Data.Context.UserEventLikes do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.{UserEventLike, User}

  @spec preload_all(UserEventLike.t()) :: UserEventLike.t()
  def preload_all(data), do: Repo.preload(data, [:like_source, :user, :item])

  def get_like_by_post_and_user_id(post_id, user_id) do
    UserEventLike
    |> where([ld], ld.item_id == ^post_id)
    |> where([ld], ld.user_id == ^user_id)
    |> Repo.one()
  end

  def is_self_liked?(user_id, post_id) do
    from(ld in UserEventLike, where: ld.item_id == ^post_id and ld.user_id == ^user_id)
    |> Repo.exists?()
  end

  def list_users_who_liked(params, page_size \\ 20)
  def list_users_who_liked(%{"post_id" => item_id, "page" => page} = params, page_size) do
    search = if params["search"], do: params["search"], else: ""
    UserEventLike
    |> join(:inner, [ld], u in User, on: u.id == ld.user_id and ld.item_id == ^item_id)
    |> where([ld], ld.liked == true)
    |> where([_ld, u], ilike(u.first_name, ^"%#{search}%"))
    |> or_where([_ld,u], ilike(u.last_name, ^"%#{search}%"))
    |> distinct([_ld, u], u.id)
    |> select([_ld, u], u)
    |> Repo.paginate(page: page, page_size: page_size)
  end


  def get_likes_count_by_item_id(item_id) do
    UserEventLike
    |> where([ld], ld.item_id == ^item_id)
    |> where([ld], ld.liked == true)
    |> select([ld], count(ld.id))
    |> Repo.one()
  end

end
