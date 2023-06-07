defmodule ApiWeb.Api.V1_0.RoomMessageView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context.{RoomMessages, UserEventCommentLikes}

  def render("room_messages.json", %{room_messages: room_messages} = data) do
    current_user_id = Map.get(data, :current_user_id)
    user_comments = Enum.map(room_messages.entries, fn message ->
      render("room_message.json", %{message: message, current_user_id: current_user_id})
    end)

    page_data = %{
      total_rows: room_messages.total_entries,
      page: room_messages.page_number,
      total_pages: room_messages.total_pages
    }
    %{data: user_comments, pagination: page_data}
  end

  def render("room_message.json", %{message: message} = data) do
    current_user_id = Map.get(data, :current_user_id)
    replies = render("comment_replies.json",
      %{comment_replies: RoomMessages.list_by_parent_id(Data.Schema.RoomMessage, message.id, 1),
        current_user_id: current_user_id})
    user = message && message.sender
    images = message && message.message_images
    %{
      id: message.id,
      selflike: current_user_id && UserEventCommentLikes.is_self_liked?(current_user_id, message.id) || false,
#      room_id: message.room_id,
      likes_count: UserEventCommentLikes.get_comment_likes_count(message.id),
      inserted_at: message.inserted_at,
      updated_at: message.updated_at,
      message: message.message,
      replies_count: RoomMessages.count_replies(message.id),
      replies: replies,
      message_images: Enum.map(images, fn image -> render("room_message_images.json", %{image: image}) end),
      sender: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user})
    }
  end

  def render("room_message_images.json", %{image: image}) do
     image.image
   end

  def render("room_message.json", %{error: error}) do
    %{errors: error}
  end


  def render("comment_replies.json", %{comment_replies: comment_replies} = data) do
    current_user_id = Map.get(data, :current_user_id)
    #    replies = render_many(comment_replies.entries, CommentReplyView, "comment_reply.json", as: :comment_reply)
    replies = Enum.map(comment_replies.entries, fn reply ->
      render("comment_reply.json", %{comment_reply: reply, current_user_id: current_user_id})
    end)
    page_data = %{
      total_rows: comment_replies.total_entries,
      page: comment_replies.page_number,
      total_pages: comment_replies.total_pages
    }
    %{data: replies, pagination: page_data}
  end

  def render("comment_reply.json", %{comment_reply: comment_reply} = data) do
    current_user_id = Map.get(data, :current_user_id)
    user = comment_reply && comment_reply.sender
    images = comment_reply && comment_reply.message_images
    %{
      id: comment_reply.id,
      comment_id: comment_reply.parent_id,
      inserted_at: comment_reply.inserted_at,
      updated_at: comment_reply.updated_at,
      images: Enum.map(images, fn image -> render("room_message_images.json", %{image: image}) end),
      message: comment_reply.message,
      selflike: current_user_id && UserEventCommentLikes.is_self_liked?(current_user_id, comment_reply.id) || false,
      likes_count: UserEventCommentLikes.get_comment_likes_count(comment_reply.id),
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user})
    }
  end

  def render("comment_reply.json", %{error: error}) do
    %{errors: error}
  end
end
