defmodule Data.Context.Comments do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.Comment
#  alias Data.Schema.UserShoutout

  @spec preload_all(Comment.t(), []) :: Comment.t()
  def preload_all(data, preloads \\ [:comment_source, :user, :parent, :shoutout]), do: Repo.preload(data, preloads)

#  @spec list_by(any(), any()) :: list(struct()) | []
  def list_by(model, by, page, page_size \\ 10) do
    from(m in model,
      where: m.shoutout_id == ^by,
    order_by: [desc: m.inserted_at])
    |> where([m], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", m.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def count_comments(post_id) do
    Comment
    |> where([c], c.shoutout_id == ^post_id)
    |> where([c], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", c.id))
    |> select([c], count(c.id))
    |> Repo.one()
  end

  def get_by_post_id(post_id, page, page_size \\ 10) do
    from(
      c in Comment,
      where: (c.shoutout_id == ^post_id and is_nil c.parent_id),
      order_by: [desc: c.inserted_at],
      preload: [:user]
    )
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_user_ids_commented_on_specific_post(shoutout_id, sender_id) do
    from(
    c in Comment,
    where: c.shoutout_id == ^shoutout_id and c.user_id != ^sender_id,
    distinct: c.user_id,
    select: c.user_id
    )
    |> Repo.all()
  end
end
