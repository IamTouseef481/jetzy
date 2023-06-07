defmodule ApiWeb.Api.V1_0.UserFriendView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserFriendView

  def render("user_friends.json", %{user_friends: user_friends}) do
    render_many(user_friends, UserFriendView, "user_friend.json")
  end

  def render("user_friend.json", %{user_friend: user_friend}) do
    user = Data.Context.preload_selective(user_friend, :friend)
    user = user.friend
    friend_interests = Data.Context.preload_selective(user, :interests)
    friend_interests = friend_interests.interests
    %{
      friend_id: user_friend.friend_id,
      friend_blocked: user_friend.friend_blocked,
      is_already_blocked: false,
      is_blocked: user_friend.is_blocked,
      is_friend: user_friend.is_friend,
      is_request_sent: user_friend.is_request_sent,
      sender_id: user_friend.user_id,
      quick_blox_id: user && user.quick_blox_id,
      image_path: user && user.image_name,
      user_small_image_path: user && user.image_name,
      blur_hash: user && user.blur_hash,
      user_name: user && user.first_name,
      user_interest: user && Enum.map_join(friend_interests, ",", fn m -> Map.from_struct(m) |> get_in([:interest_name]) end)
    }
  end

  def render("user_friend.json", %{user_friend: user_friend, friend: friend}) do
    %{
      friend_id: user_friend.friend_id,
      friend_blocked: user_friend.friend_blocked,
      is_already_blocked: false,
      is_blocked: user_friend.is_blocked,
      is_friend: user_friend.is_friend,
      is_request_sent: user_friend.is_request_sent,
      sender_id: user_friend.user_id,
      quick_blox_id: friend.quick_blox_id,
      image_path: friend.image_name,
      user_small_image_path: friend.image_name,
      blur_hash: friend.blur_hash,
      user_name: friend.first_name,
      user_interest: Enum.map_join(friend.interests, ",", fn m -> Map.from_struct(m) |> get_in([:interest_name]) end)
    }
  end

  def render("user_friend.json", %{error: error}) do
    %{errors: error}
  end
end
