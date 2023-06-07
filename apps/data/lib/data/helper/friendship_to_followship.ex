defmodule Data.Helper.FriendshipToFollowship do
  @moduledoc false
  alias Data.Repo, as: MyRepo
  alias Data.Schema.UserFriend
  alias Data.Schema.UserFollow
  import Ecto.Query

  def tranfer_friends_to_followers(skip \\ 0, next \\ 400) do
    q = UserFriend |> limit(^next) |> offset(^skip)
    case MyRepo.all(q) do
      rows ->
          Enum.reduce(rows, %{}, fn row, _map ->
            if row.is_friend do
              do_transfer(row.user_id, row.friend_id)
              do_transfer(row.friend_id, row.user_id)
            else
              if row.is_request_sent, do: do_transfer(row.user_id, row.friend_id)
            end
          end)

         if Enum.count(rows) > 0 do
           tranfer_friends_to_followers(next + skip, next)
         end
    end
  end

  defp do_transfer(followed_id, follower_id) do
    #check followed_id and follower_id existence in follow
    case MyRepo.get_by(UserFollow, [followed_id: followed_id, follower_id: follower_id]) do
      nil  ->
        obj = %UserFollow{id: UUID.uuid1(), followed_id: followed_id, follower_id: follower_id, follow_status: :followed}
        cs = UserFollow.changeset(obj, %{})
        _resp = MyRepo.insert_or_update(cs)

      obj ->
        obj          # obj exists, let's use it
    end
  end

end
