defmodule Data.Context.UserFriends do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context.UserBlocks
  alias Data.Schema.{UserFriend, User}

  @spec preload_all(UserFriend.t()) :: UserFriend.t()
  def preload_all(data), do: Repo.preload(data, [:user, :friend, ])

  def check_friend_request_exist(user_id, friend_id) do
    UserFriend
    |> where([uf], uf.user_id == ^user_id)
    |> where([uf], uf.friend_id == ^friend_id)
    |> Repo.one()
  end

  def get_friends_by_user_id(user_id) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)

    UserFriend
    |> join(:inner, [uf], u in User, on: u.id == uf.friend_id)
    |> where([uf, _], uf.user_id == ^user_id and uf.is_friend == true)
    |> where([_, u], u.id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false)
    |> Repo.all()
  end

  def get_no_of_friends_by_user_id(user_id) do
    UserFriend
    |> where([uf], uf.friend_id == ^user_id)
    |> select([uf], count(uf.id))
    |> Repo.one()
  end

  def get_no_of_following_by_user_id(user_id) do
    UserFriend
    |> where([uf], uf.user_id == ^user_id)
    |> select([uf], count(uf.id))
    |> Repo.one()
  end
end
