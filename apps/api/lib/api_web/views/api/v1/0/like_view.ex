defmodule ApiWeb.Api.V1_0.LikeView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context
  alias Data.Schema.RoomMessageMeta
  def render(
        "like_detail.json",
        %{"liked" => liked, "item_id" => item_id} = _params
      ) do
    total_likes = Data.Context.UserEventLikes.get_likes_count_by_item_id(item_id)

    %{
      is_deleted: false,
      item_id: item_id,
      status: true,
      total_likes: total_likes,
      user_self_like: liked
    }
  end

  def render(
        "like_comment.json",
        %{"is_liked" => is_liked, "comment_id" => comment_id, "current_user_id" => _current_user_id} = _params
      ) do
    %{
      is_deleted: false,
      comment_id: comment_id,
      status: true,
      is_liked: is_liked
    }
  end

  def render("like_detail.json", %{error: error}) do
    %{errors: error}
  end

  def render("liked_by.json", %{users: users}) do
    user = Enum.map(users, fn user ->
      ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user})
    end)
    page_data = %{
      total_rows: users.total_entries,
      page: users.page_number,
      total_pages: users.total_pages
    }
    %{
      data: user, pagination: page_data
    }
  end


  def render("liked_by.json", %{message: message}) do
    %{message: message}
  end

  def render("comment_like.json", %{room_message: room_message}) do
    %{
      is_deleted: false,
      item_id: room_message.id,
      total_likes: get_counts_from_meta(room_message.id),
      description: room_message.message
    }
  end
  defp get_counts_from_meta(room_message_id) do
    case Context.get_by(RoomMessageMeta, [room_message_id: room_message_id]) do
      %{no_of_likes: likes} ->
        likes
      nil ->
        0
    end
  end
end
