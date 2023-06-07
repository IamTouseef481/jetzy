defmodule ApiWeb.Api.V1_0.CommentReplyView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context.UserEventCommentLikes

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
      description: comment_reply.message,
      message_images: Enum.map(images, fn image -> render("comment_reply_images.json", %{image: image}) end),
      selflike: current_user_id && UserEventCommentLikes.is_self_liked?(current_user_id, comment_reply.id) || false,
      likes_count: UserEventCommentLikes.get_comment_likes_count(comment_reply.id),
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user})
    }
  end

  def render("comment_reply_images.json", %{image: image}) do
    image.image
  end

  def render("comment_reply.json", %{error: error}) do
    %{errors: error}
  end
end
