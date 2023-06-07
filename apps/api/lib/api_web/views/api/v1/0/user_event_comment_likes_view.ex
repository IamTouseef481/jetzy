defmodule ApiWeb.Api.V1_0.UserEventCommentLikesView do
  @moduledoc false
  use ApiWeb, :view
#  alias ApiWeb.Api.V1_0.LikeView
  alias Data.Context
  alias Data.Schema.RoomMessageMeta

  def render("room_message_like.json", %{"room_message_id"=> room_message_id, "liked_by_id"=> _liked_by_id, "id" => _id} = _params) do
#    %{
#      room_message_id: room_message_id,
#      id: id,
#      liked_by_id: liked_by_id
#    }
    %{
        is_deleted: false,
        item_id: room_message_id,
        item_type: "",
        status: true,
        total_likes: get_counts_from_meta(room_message_id),
#        user_self_like: true
      }
  end

  def render("room_message_like.json", %{error: error}) do
    %{errors: error}
  end
  def render("message.json", %{message: message}) do
    %{message: message}
  end
  def render("like.json", %{like: like}) do
    %{
        is_deleted: false,
        item_id: like.room_message_id,
        item_type: "",
        status: true,
        total_likes: get_counts_from_meta(like.room_message_id),
#        user_self_like: true
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
