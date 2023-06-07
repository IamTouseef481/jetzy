defmodule Data.Context.UserBlocks do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{UserBlock, User}
  require Logger

  def preload_all(data), do: Repo.preload(data, [:user_from, :user_to])

  def preload_blocked_users(data), do: Repo.preload(data, [:user_to])

  def get_by_user(user_from_id, page, page_size \\ 10) do
    from(ub in UserBlock, where: ub.user_from_id == ^user_from_id)
    |> join(:inner, [ub], u in User, on: ub.user_to_id == u.id)
    |> where([_, u], u.is_deleted == false and u.is_deactivated == false)
    |> where([ub, _], ub.is_blocked)
    |> select([_, u], u)
    |> distinct([u], u.id)
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def get_blocked_user_ids(user_id) do
    from(ub in UserBlock,
      where: ub.user_from_id == ^user_id and ub.is_blocked,
      select: ub.user_to_id)
    |> Repo.all()
  end

  def get_blocked_by_user_ids(user_id) do
    from(ub in UserBlock,
      where: ub.user_to_id == ^user_id and ub.is_blocked,
      select: ub.user_from_id)
    |> Repo.all()
  end

  def get_blocked_status(user_1_id, user_2_id) do
    UserBlock
    |> where([ub], ub.user_from_id == ^user_1_id and ub.user_to_id == ^user_2_id and ub.is_blocked)
    |> or_where([ub], ub.user_to_id == ^user_1_id and ub.user_from_id == ^user_2_id and ub.is_blocked)
    |> Repo.exists?()
  end

  def get_from_user(user_to_id) do
    UserBlock
    |> join(:inner, [ub], u in User, on: u.id == ub.user_to_id)
    |> where([ub], ub.user_to_id == ^user_to_id)
    |> where([ub, _], ub.is_blocked)
    |> select([u], u)
    |> Repo.all()
  end

  def delete_block_records_by_user_id(_, _, user_id) do
    try do
      UserBlock
      |> where([ub], ub.user_from_id == ^user_id or ub.user_to_id == ^user_id)
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now()]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end
end
