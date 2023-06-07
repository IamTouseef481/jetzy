defmodule Data.Context.UserShoutouts do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{UserShoutout, User}

  @spec preload_all(UserShoutout.t()) :: UserShoutout.t()
  def preload_all(data), do: Repo.preload(data, [:user, :shoutout_type, :post_type])
  def preloads(data, preloads), do: Repo.preload(data, preloads)

  def get_post_count_by_user_id(user_id) do
    UserShoutout
    |> where([us], us.user_id == ^user_id)
    |> select([us], count(us.id))
    |> Repo.one()
  end

  def paginate(query, page, page_size \\ 10) do
    query
    |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
    |> select([q], q)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_user_by_shout_id(shout_id) do
    UserShoutout
    |> join(:inner, [us], u in User, on: u.id == us.user_id)
    |> where([us, _], us.id == ^shout_id)
    |> select([_, u], %{id: u.id, email: u.email})
    |> Repo.one()
  end

  def soft_delete_post(%UserShoutout{} = shoutout)do
    shoutout
    |> UserShoutout.changeset(%{is_deleted: true, deleted_at: DateTime.utc_now})
    |> Repo.update()
  end
end
