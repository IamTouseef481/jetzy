defmodule Data.Context.UserFollows do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{UserFollow, UserSetting}

  @spec preload_all(UserFollow.t()) :: UserFollow.t()
  def preload_all(data), do: Repo.preload(data, [:follower, :followed])

  def check_follow_request_exist(followed_id, follower_id) do
    UserFollow
    |> where([uf], uf.followed_id == ^followed_id and uf.follower_id == ^follower_id)
#    |> where([uf], uf.follow_status == :followed )
    |> Repo.one()
  end

  def check_followed_user_setting(followed_id)do
    UserSetting
    |> where([us], us.user_d == ^followed_id)
    |> Repo.one
  end


  def get_followed_by_follower_id_of_current_user(follower_id, page, page_size \\ 20) do
    UserFollow
    |> where([uf], uf.follower_id == ^follower_id and uf.follow_status == ^"followed")
    |> preload([:followed])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_follower_by_followed_id_of_current_user(followed_id, page, page_size \\ 20) do
    UserFollow
    |> where([uf], uf.followed_id == ^followed_id and uf.follow_status == ^"followed")
    |> preload([:follower])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_followed_by_follower_id_of_other_user(follower_id, page, page_size \\ 20) do
    UserFollow
    |> join(:inner, [uf], us in UserSetting, on: uf.follower_id == us.user_id)
    |> where([uf, us], uf.follower_id == ^follower_id and uf.follow_status == ^"followed" and us.is_show_followings == true)
    |> preload([:followed])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_follower_by_followed_id_of_other_user(followed_id, page, page_size \\ 20) do
    UserFollow
    |> join(:inner, [uf], us in UserSetting, on: uf.followed_id == us.user_id)
    |> where([uf, us], uf.followed_id == ^followed_id and uf.follow_status == ^"followed" and us.is_show_followings == true)
    |> preload([:follower])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_followed_count(user_id) do
    UserFollow
    |> where([uf], uf.follower_id == ^user_id and uf.follow_status == ^"followed")
    |> select([uf], count(uf.followed_id))
    |> Repo.one
  end

  def get_follower_count(user_id) do
    UserFollow
    |> where([uf], uf.followed_id == ^user_id and uf.follow_status == ^"followed")
    |> select([uf], count(uf.follower_id))
    |> Repo.one
  end


  def get_user_by_followed_or_follower_id_and_follow_status(followed_id, follower_id) do
    UserFollow
    |>where([uf], uf.followed_id == ^followed_id and uf.follower_id == ^follower_id)
    |>where([uf], uf.follow_status == :requested)
    |>Repo.one()
  end

def get_requested_users_by_follower_id(followed_id, page, page_size \\ 10) do
  UserFollow
  |>where([uf], uf.followed_id == ^followed_id and uf.follow_status == :requested)
  |> preload([uf], [:follower])
  |>Repo.paginate([page: page, page_size: page_size])
  end


#  def get_follows_by_user_id(user_id) do
#    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)
#
#    UserFollow
#    |> join(:inner, [uf], u in User, on: u.id == uf.follower_id)
##    |> where([uf, _], uf.user_id == ^user_id and uf.is_friend == true)
#    |> where([_, u], u.id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false)
#    |> Repo.all()
#  end

  def get_user_follow_status(user_id, current_user_id) do
    UserFollow
    |> where([uf], uf.follower_id == ^current_user_id and uf.followed_id == ^user_id)
    |> select([uf], uf.follow_status)
    |> Repo.one
  end


  @doc """
    Is current user following user_id
  """
  def get_user_following_status(user_id, current_user_id) do
    UserFollow
    |> where([uf], uf.follower_id == ^current_user_id and uf.followed_id == ^user_id)
    |> select([uf], uf.follow_status)
    |> Repo.one
  end

  @doc """
    Is current user followed by user_id
  """
  def get_user_followed_status(user_id, current_user_id) do
    UserFollow
    |> where([uf], uf.followed_id == ^current_user_id and uf.follower_id == ^user_id)
    |> select([uf], uf.follow_status)
    |> Repo.one
  end

  def delete_follow_following_record_by_user_id(_, _, user_id) do
    try do
      UserFollow
      |> where([uf], uf.followed_id == ^user_id or uf.follower_id == ^user_id)
      |> where([uf], is_nil(uf.deleted_at))
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end
end
