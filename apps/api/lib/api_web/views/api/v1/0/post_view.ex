defmodule ApiWeb.Api.V1_0.PostView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.PostView
  alias Data.Context.RoomMessages
  alias Data.Context.{UserEventLikes, UserEvents}

  def render("posts.json", %{posts: posts} = data) do
    current_user_id = Map.get(data, :current_user_id)
    data = Enum.map(
      posts.entries,
      fn entry ->
        render("post.json", %{post: entry, current_user_id: current_user_id})
      end
    )
    page_data = %{
      total_rows: posts.total_entries,
      page: posts.page_number,
      total_pages: posts.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("post.json", %{post: post} = data) do
    user = post.user
    current_user_id = Map.get(data, :current_user_id)

    room_messages = ApiWeb.Api.V1_0.RoomMessageView.render("room_messages.json",
      %{
      room_messages: RoomMessages.get_by_room_id(post.room_id, 1)|> Map.from_struct(),
      current_user_id: current_user_id})
    tags =
      post.post_tags &&
        ApiWeb.Api.V1_0.UserView.render("users.json",
          %{users: UserEvents.user_for_post_tags(post.post_tags)})

#    address_component = Data.Context.AddressShoutoutMappings.get_by_shoutout_id(post.id)
    %{
      id: post.id,
      address_components: [],
      comments_count: RoomMessages.count_room_messages(post.room_id),
      comments: room_messages,
      created_date: post.inserted_at,
      description: post.description,
      distance: post.distance,
      distance_unit: post.distance_unit || "miles",
      group_list: [],
      home_address: post.user && post.user.home_town_city,
      is_private: false,
      likes_count: UserEventLikes.get_likes_count_by_item_id(post.id),
      selflike: current_user_id && UserEventLikes.is_self_liked?(current_user_id, post.id) || false,
      user_event_images: post.user_event_images == [] &&  [%{id: nil, image: user.image_name, image_thumbnail: user.small_image_name}] ||
        render_many(post.user_event_images, PostView, "user_event_images.json", as: :user_event_image),
      latitude: post.latitude,
      longitude: post.longitude,
      room_id: post.room_id,
      post_tags: tags,
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user}),
      user_small_image_path: post.user && post.user.image_name,
      user_blur_hash: post.user && post.user.blur_hash,
      formatted_address: post.formatted_address,
      shareable_link_feed: post.shareable_link_feed,
      shareable_link_event: post.shareable_link_event,
      interest_id: post.interest_id,
      interest_name: post.interest && post.interest.interest_name
    }

#    case address_component do
#        nil -> post
#        _ ->
#          Map.merge(post, post_address_components_mapping(address_component))
#      end
  end
  def render("user_event_images.json", %{user_event_image: user_event_image}) do
    %{
      id: user_event_image.id,
      image: user_event_image.image,
      image_thumbnail: user_event_image.small_image || "mnt/images/jetzy/post/ec3/585/ec35854e47634f7a819a00e3403f91a2/base.thumb.jpg",
      blur_hash: user_event_image.blur_hash,
    }
  end
  def render("post.json", %{error: error}) do
    %{errors: error}
  end

  def render("create.json", %{post: post} = data) do
      current_user_id = data.conn && data.conn.assigns &&
        data.conn.assigns.current_user && data.conn.assigns.current_user.id || nil
      %{user_event: render("post.json", %{post: post, current_user_id: current_user_id})}
  end

  # @todo remove after may 2022
  #  defp post_address_components_mapping(map) do
  #    main = %{place_id: map.place_id,
  #      location_address: map.formatted_address, url: map.url}
  #    map = Map.drop(map, [:place_id, :formatted_address, :url]) |> Map.to_list()
  #    address_components =
  #      Enum.map(map, fn {x, y} ->
  #        case y do
  #          nil -> nil
  #          _ -> %{types: x, long_name: y}
  #        end
  #      end)
  #      |> Enum.filter(&(!is_nil(&1)))
  #    Map.put(main, :address_components, address_components)
  #  end

  def render("map_posts.json", %{map_posts: map_posts}) do
    data = render_many(map_posts, PostView, "map_post.json", as: :map_post)
    page_data = %{
      total_rows: map_posts.total_entries,
      page: map_posts.page_number,
      total_pages: map_posts.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("map_post.json", %{map_post: map_post}) do
    images = map_post && render_many(map_post.user_event_images, PostView, "user_event_images.json", as: :user_event_image)
    images = case images do
      [] ->
        [%{
        id: nil,
        image: nil,
        blur_hash: nil,
        small_image: "mnt/images/jetzy/post/ec3/585/ec35854e47634f7a819a00e3403f91a2/base.thumb.jpg"
      }]
      |> render_many(PostView, "user_event_images.json", as: :user_event_image)
      _ -> images
    end
    %{id: map_post.id, latitude: map_post.latitude, longitude: map_post.longitude, images: images}
  end
end
