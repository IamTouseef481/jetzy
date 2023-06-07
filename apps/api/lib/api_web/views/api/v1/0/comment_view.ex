defmodule ApiWeb.Api.V1_0.CommentView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context.{RoomMessages, UserEventCommentLikes}

  def render("comments.json", %{comments: comments, post_id: post_id} = data) do
    current_user_id = Map.get(data, :current_user_id)
    user_comments = Enum.map(comments.entries, fn comment ->
      render("comment.json", %{comment: comment, current_user_id: current_user_id, post_id: post_id})
    end)

    page_data = %{
      total_rows: comments.total_entries,
      page: comments.page_number,
      total_pages: comments.total_pages
    }
    %{data: user_comments, pagination: page_data}
  end

  def render("comment.json", %{comment: comment} = data) do
    current_user_id = Map.get(data, :current_user_id)
    post_id = Map.get(data, :post_id)

    replies = RoomMessages.list_by_parent_id(Data.Schema.RoomMessage, comment.id, 1)
    replies_view = ApiWeb.Api.V1_0.CommentReplyView.render("comment_replies.json", %{comment_replies: replies, current_user_id: current_user_id})
    user = comment && comment.sender
    images = comment && comment.message_images
     %{
      id: comment.id,
      likes_count: UserEventCommentLikes.get_comment_likes_count(comment.id),
      selflike: current_user_id && UserEventCommentLikes.is_self_liked?(current_user_id, comment.id) || false,
      post_id: post_id,
      inserted_at: comment.inserted_at,
      updated_at: comment.updated_at,
      description: comment.message,
      replies_count: RoomMessages.count_replies(comment.id),
      message_images: Enum.map(images, fn image -> render("comment_images.json", %{image: image}) end),
      replies: replies_view,
      user: %{
        user_id: user && user.id,
        first_name: user && user.first_name,
        last_name: user && user.last_name,
        user_image: user && user.image_name
      }
    }
  end

  def render("comment_images.json", %{image: image}) do
    image.image
  end

  def render("comment.json", %{error: error}) do
    %{errors: error}
  end
end
