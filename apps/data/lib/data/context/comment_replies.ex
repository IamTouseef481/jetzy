defmodule Data.Context.CommentReplies do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{CommentReply, Comment, User}

  @spec preload_all(CommentReply.t()) :: CommentReply.t()
  def preload_all(data), do: Repo.preload(data, [:parent_comment, :child_comment, ])

  def list_by_parent_id(model, id, page, page_size \\ 10) do
    from(m in model,
      where: m.parent_id == ^id,
      order_by: [desc: m.inserted_at],
      preload: [:user])
    |> where([m], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", m.id))
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def count_replies(comment_id) do
    Comment
    |> where([c], c.parent_id == ^comment_id)
    |> where([c], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", c.id))
    |> select([c], count(c.id))
    |> Repo.one()
  end

  def get_user_by_parent_sref(parent_sref) do
    Comment
    |> join(:inner, [us], u in User, on: u.id == us.user_id)
    |> where([us, _], us.id == ^parent_sref)
    |> select([us, u], %{id: u.id, email: u.email, user_id: us.user_id})
    |> Repo.one()
  end

end
