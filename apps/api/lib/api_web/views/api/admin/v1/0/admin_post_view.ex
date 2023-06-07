defmodule ApiWeb.Api.V1_0.AdminPostView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context
  alias ApiWeb.Api.V1_0.AdminPostView

  def render("posts.json", %{posts: posts}) do
    post = render_many(posts.entries, AdminPostView, "post.json", as: :post )
    page_data = %{
      total_rows: posts.total_entries,
      page: posts.page_number,
      total_pages: posts.total_pages,
      page_size: posts.page_size
    }
    %{data: post, pagination: page_data}
  end

  def render("admin_posts.json", %{posts: posts}) do
    render_many(posts, AdminPostView, "post.json", as: :post )
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("post.json", %{post: post}) do
    total_likes = Data.Context.UserEventLikes.get_likes_count_by_item_id(post.id)
    total_comments = post.room_id && Data.Context.RoomMessages.count_room_messages(post.room_id)
    {image, small_image} = cond do
                    post.small_image -> {post.image,  post.small_image}
                    :else ->
                    case post.user_event_images do
                      [h|_] -> {h.image,  h.small_image}
                      _ -> {nil, nil}
                    end
                  end
    %{
      identifier: post .id,
      user: post.user && post.user.id,
      longitude: post.longitude,
      latitude: post.latitude,
      first_name: post.user && post.user.first_name || nil,
      last_name:  post.user && post.user.last_name || nil,
      interst_name: post.interest && post.interest.interest_name || nil,
      description: post.description,
      total_comments: total_comments,
      total_likes: total_likes,
      posted_date: post.inserted_at,
      address: post.formatted_address,
      
      image: image,
      thumbnail: small_image,
    }
  end

end
