#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.PostController do
  @moduledoc """
  User Post Api.
  @todo clean up filterable section.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger
  alias Data.Repo
  alias Data.Context
  alias Data.Context.Users
  alias ApiWeb.Utils.Common
  alias Data.Schema.{
    UserEvent,
#    UserInterest,
    UserShoutoutsImage,
    AddressComponent,
    AddressShoutoutMapping,
    User,
    UserGeoLocation
 }

  alias Data.Context.{UserBlocks, UserEvents, NotificationsRecords}
  alias JetzyModule.AssetStoreModule, as: AssetStore
  alias ApiWeb.Api.V1_0.UserEventController

  #============================================================================
  # filterable
  #============================================================================
  filterable do
    #    paginateable(per_page: 20)

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    # @todo remove after may 2022
    #    defp to_float(str) do
    #      if String.contains?(str, "."),
    #         do: String.to_float(str),
    #         else: String.to_integer(str)
    #    end

    @options default: ""
    filter base_query(query, _value, conn) do
      current_user = Guardian.Plug.current_resource(conn)

#      latitude = if is_nil(current_user.latitude), do: nil, else: to_float(current_user.latitude)
#      longitude = if is_nil(current_user.longitude), do: nil, else: to_float(current_user.longitude)
      query
      |> join(:inner, [ue], u in assoc(ue, :user))
        #      |> where([_, u], u.is_active == true)
      |> where([_, u], u.effective_status == :active)
#      |> where([us, _], us.is_deleted == false)
      |> (fn query ->
        case current_user do
          nil ->
            query

          _ ->
            where(
              query,
              [_, u],
              fragment(
                "? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)",
                u.id,
                ^UUID.string_to_binary!(current_user.id)
              )
            )
        end
          end).()

    # |> distinct([ue], [desc: ue.id])
      # |> group_by([ue], ue.id)
    end



    #    filter post_type_id(query, value, _conn) do
    #      query
    #      |> where(post_type_id: ^value)
    #    end
    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter event_start_time(query, value, _conn) do
      value = Common.convert_time_string_to_time_format(value)
      query
      |> where([ue], ue.event_start_time >= ^value)
      |> order_by([ue], asc: ue.event_start_time)
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter event_end_time(query, value, _conn) do
      value = Common.convert_time_string_to_time_format(value)
      query
      |> where([ue], ue.event_end_time <= ^value)
      |> order_by([ue], desc: ue.event_end_time)
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter event_start_date(query, value, _conn) do
      value = Common.convert_date_string_to_date_format(value)
      query
      |> where([ue, u], ue.event_start_date >= ^value)
      |> order_by([ue], asc: ue.event_start_date)
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter event_end_date(query, value, _conn) do
      value = Common.convert_date_string_to_date_format(value)
      query
      |> where([ue], ue.event_end_date <= ^value)
      |> order_by([ue], desc: ue.event_end_date)
    end

    # @todo delete after may 2022
    # filter first_name(query, value, _conn) do
    #   query
    #   |> where([us, u], ilike(u.first_name, ^"%#{value}%"))
    # end

    # @todo delete after may 2022
    # filter last_name(query, value, _conn) do
    #   query
    #   |> where([us, u], ilike(u.last_name, ^"%#{value}%"))
    # end

    # @todo delete after may 2022
    # filter gender(query, value, _conn) do
    #   query
    #   |> where([us, u], ilike(u.gender, ^"%#{value}%"))
    # end

#    @options param: [:user_latitude, :user_longitude], cast: :float
#    filter filter_by_location(
#             query,
#             %{user_latitude: latitude, user_longitude: longitude} = value,
##                   , distance: distance},
#             _conn
#           ) do
#        query
#        |> order_by(
#             [u],
#             fragment(
#               "case when ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))<=10000 then 'A'
#               when ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))<=1000000 then 'B'
#           else 'Z' end",
#           u.latitude,
#           u.longitude,
#           ^latitude,
#           ^longitude,
#           u.latitude,
#           u.longitude,
#           ^latitude,
#           ^longitude
#             )
#           )
#    end


    @options param: [:user_latitude, :user_longitude, :radius, :distance_unit]
    filter filter_by_location(query, %{user_latitude: latitude, user_longitude: longitude, radius: radius, distance_unit: distance_unit}, _conn) do
      if !is_nil(latitude) && !is_nil(longitude) && !is_nil(radius) do
        latitude = Common.string_to_float(latitude)
        longitude = Common.string_to_float(longitude)
        radius = Common.string_to_float(radius)

        # radius = if is_nil(radius) , do: 50.0, else: radius
        {distance, multiplication_factor} =  case distance_unit do
          "km" -> {1.60934 * radius, 0.621372736649807}
          _ -> {radius, 1}
        end
        query
        |> where(
            [ue],
            fragment(
              "ceil((point(?,?) <@> point(?,?))/?)<=?",
              ue.longitude,
              ue.latitude,
              ^longitude,
              ^latitude,
              ^multiplication_factor,
              ^distance
            )
          )
      else
        query
      end
    end

    filter gender(query, value, _conn) do
      query
      |> where([ue, u], u.gender == ^"#{value}")
    end

    filter age_from(query, value, _conn) do
      query
      |> where([ue, u], u.age >= ^value)
    end

    filter age_to(query, value, _conn) do
      query
      |> where([ue, u], u.age <= ^value)
    end

    # filter city(query, value, _conn) do
    #   query
    #   |> where([_, u], ilike(u.current_city, ^"#{value}"))
    # end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    # filter interest_ids(query, value, _conn) do
    #   value = Enum.map(value, fn x ->
    #     case Ecto.UUID.cast(x) do
    #       :error -> nil
    #       {:ok, v} -> v
    #       # UUID.string_to_binary!(v)
    #     end
    #   end)
    #   # query
    #   # |> where([ue], [desc: ue.interest_id in ^Poison.decode!(value)])
    #   query
    #   |> order_by([ue], [desc: ue.interest_id in ^value])
    # end

    filter post_ids(query, value, _conn) do
      value = Enum.map(value, fn x ->
        case Ecto.UUID.cast(x) do
          :error -> nil
          {:ok, v} -> v
          # UUID.string_to_binary!(v)
        end
      end)
      query
      |> where([ue, _u], ue.id in ^value)
    end
  end

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    post("/v1.0/timeline")
    summary("Timeline")
    description("Timeline")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body :body, Schema.ref(:Timeline), "Timeline", required: true
    end

    response(200, "Ok", Schema.ref(:ListPost))
  end

  @doc """
  List/query posts for authenticated user.
  """
  def index(conn, params) do
    page = params["page"] || 1
    distance_unit = params["distance_unit"] || "miles"
    interest_ids = params["interest_ids"] || []
    %{id: user_id, latitude: lat, longitude: long} = Api.Guardian.Plug.current_resource(conn)
#    Users.create_geo_loc_and_geo_loc_log(params, user_id)
    #    latitude = params["user_latitude"] || lat
    #    longitude = params["user_longitude"] || long
    %{latitude: latitude, longitude: longitude} =
      case Context.get_by(UserGeoLocation, %{user_id: user_id}) do
        nil -> %{latitude: lat, longitude: long}
        output -> output
    end
    with {:ok, query, _filter_values} <- apply_filters(UserEvent, conn),
          posts <- UserEvents.paginate(query, latitude, longitude, distance_unit, interest_ids, user_id, page) do
          entries = UserEvents.preload_all(posts.entries)
          render(conn, "posts.json", %{posts: Map.merge(posts, %{entries: entries}), current_user_id: user_id})
      end
  end

  #----------------------------------------------------------------------------
  # personal_post_feed/2
  #----------------------------------------------------------------------------
  swagger_path :personal_post_feed do
    get("/v1.0/personal-post-feed")
    summary("Get Post By USER ID")
    description("Get Post By USER ID")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      user_id(:query, :string, "User ID.")
      page(:query, :integer, "Page", required: true)
    end
    response(200, "Ok", Schema.ref(:ListPost))
  end

  def personal_post_feed(conn, %{"page" => page} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    user_id = if params["user_id"] do
      params["user_id"]
    else
      current_user_id
    end
   case UserEvents.get_my_feed_events_by_user_id(user_id, page) do
     posts -> entries = UserEvents.preload_all(posts.entries)
     render(conn, "posts.json", %{posts: Map.merge(posts, %{entries: entries}), current_user_id: current_user_id})
    end

  end

  #----------------------------------------------------------------------------
  # index_for_guest/2
  #----------------------------------------------------------------------------
  swagger_path :index_for_guest do
    post("/v1.0/guest/timeline")
    summary("Timeline")
    description("Timeline")
    produces("application/json")

    parameters do
      body :body, Schema.ref(:Timeline), "Timeline", required: true
    end

    response(200, "Ok", Schema.ref(:ListPost))
  end

  @doc """
    List/Query posts for Guest Authenticated user.
  """
  def index_for_guest(conn, params) do
    page = params["page"] || 1
    distance_unit = params["distance_unit"] || "miles"
    lat = params["user_latitude"] || nil
    long = params["user_longitude"] || nil
    interest_ids = params["interest_ids"] || []
    with {:ok, query, _filter_values} <- apply_filters(UserEvent, conn),
         posts <- UserEvents.guest_paginate(query,lat, long, distance_unit, interest_ids, page) do
          entries = UserEvents.preload_all(posts.entries)
          render(conn, "posts.json", %{posts: Map.merge(posts, %{entries: entries})})
      end
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/posts/{id}")
    summary("Get Post By ID")
    description("Get Post By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Post ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Posts))
  end

  @doc """
  Get specific post.
  """
  def show(conn, %{"id" => id}) do
    %{id: current_user_id} = Guardian.Plug.current_resource(conn)
    blocked_user_ids = UserBlocks.get_blocked_user_ids(current_user_id)

    with %{user_id: user_id} = post <- Context.get(UserEvent, id),
         %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} <- Context.get(User, user_id),
         false <- is_deleted or is_deactivated or is_self_deactivated,
         true <- user_id not in blocked_user_ids do
            post = UserEvents.preload_all(post)
            render(conn, "post.json", %{post: post, current_user_id: current_user_id})
      else
        nil -> render(conn, "post.json", %{error: "post does not exist"})
        true -> render(conn, "post.json", %{error: "User deleted or deactivated"})
        false -> render(conn, "post.json", %{error: "The User is blocked"})
        _ -> render(conn, "post.json", %{error: "Something went wrong."})
    end
  end

  #----------------------------------------------------------------------------
  # guest_show/2
  #----------------------------------------------------------------------------

  swagger_path :show_guest_post do
    get("/v1.0/guest/posts/{id}")
    summary("Get Guest  Post By ID")
    description("Get Guest Post By ID")
    produces("application/json")

    parameters do
      id(:path, :string, "Post ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Posts))
  end

  @doc """
  Get specific post.
  """
  def show_guest_post(conn, %{"id" => id}) do

    with %{user_id: user_id} = post <- Context.get(UserEvent, id),
         %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} <- Context.get(User, user_id),
         false <- is_deleted or is_deactivated or is_self_deactivated do
      post = UserEvents.preload_all(post)
      render(conn, "post.json", %{post: post})
    else
      nil -> render(conn, "post.json", %{error: "post does not exist"})
      true -> render(conn, "post.json", %{error: "User deleted or deactivated"})
      _ -> render(conn, "post.json", %{error: "Something went wrong."})
    end
  end


  # @todo delete after may 2022
  # #----------------------------------------------------------------------------
  # # create/2
  # #----------------------------------------------------------------------------
  #  swagger_path :create do
  #    post("/v1.0/posts")
  #    summary("Create New Post")
  #    description("Create a new from post")
  #    produces("application/json")
  #    security([%{Bearer: []}])
  #
  #    parameters do
  #      body(:body, Schema.ref(:CreatePost), "Create a new post from params", required: true)
  #    end
  #
  #    response(200, "Ok", Schema.ref(:Posts))
  #  end
  #  def create(conn, params) do
  #    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
  #    address_component_params = post_address_components_mapping(params)
  #
  #    case Context.create(UserEvent, Map.put(params, "user_id", user_id)) do
  #      {:ok, post} ->
  #        ApiWeb.Utils.Common.update_points(user_id, 1, "Posted photo")
  #        case AssetStore.upload_if_image(params, "shoutout_images", "shoutout") do
  #          nil -> nil
  #          img_urls when is_list(img_urls)  ->
  #            Enum.map(img_urls, fn
  #              nil -> nil
  #              img_url ->
  #                Context.create(UserShoutoutsImage, %{
  #                  shoutout_images: img_url,
  #                  shoutout_id: post.id
  #                })
  #            end)
  #          [] -> []
  #          _ -> nil
  #        end
  #
  #        case Context.create(AddressComponent, address_component_params) do
  #          {:ok, address_component} ->
  #            Context.create(AddressShoutoutMapping, %{
  #              address_component_id: address_component.id,
  #              shoutout_id: post.id
  #            })
  #          {:error, %Ecto.Changeset{} = changeset} ->
  #            render(conn, "post.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
  #          {:error, _error} ->
  #            nil
  #        end
  #        render(conn, "create.json", %{post: UserEvents.preload_all(post)})
  #      {:error, %Ecto.Changeset{} = changeset} ->
  #        render(conn, "post.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
  #      {:error, error} -> render(conn, "post.json", %{error: error})
  #      _ -> render(conn, "post.json", %{error: "Something went wrong"})
  #    end
  #  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/posts/{id}")
    summary("Update Post")
    description("Update Post")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Post ID", required: true)
      body(:body, Schema.ref(:UpdatePost), "Update Post Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Posts))
  end

  @doc """
  Update a post.
  """
  def update(conn, %{"id" => id} = params) do
    address_component_params = post_address_components_mapping(params)
    with %UserEvent{} = post <- Context.get(UserEvent, id),
          params <- UserEventController.add_or_remove_tags(params, post),
          params <- UserEventController.update_image(params, post),
         {:ok, %UserEvent{} = post} <- Context.update(UserEvent, post, params) do
      if !is_nil(params["shoutout_images"]) do
        Enum.with_index(params["shoutout_images"], 1)
        |> Enum.each(fn {image, _key} ->
          {:ok, img_url} = AssetStore.upload_image(image, "shoutout")

          Context.create(UserShoutoutsImage, %{
            shoutout_images: img_url,
            shoutout_id: id
          })
        end)
      end

      case Context.create(AddressComponent, address_component_params) do
        {:ok, address_component} ->
          Context.AddressShoutoutMappings.delete_shoutout_address_mapings(id)
          Context.create(AddressShoutoutMapping, %{
            address_component_id: address_component.id,
            shoutout_id: id
          })

        {:error, _error} ->
          nil
      end

      render(conn, "create.json", %{post: UserEvents.preload_all(post)})
    else
      nil -> render(conn, "post.json", %{error: ["Post not found"]})
      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "post.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      {:error, error} -> render(conn, "post.json", %{error: error})
      _ -> render(conn, "post.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/posts/{id}")
    summary("Delete Post")
    description("Delete Post")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Post ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Posts))
  end

  @doc """
  Delete a post.
  """
  def delete(conn, %{"id" => id} = _params) do #TODO - Resolve the foreign key constraint error (b/w like_details and posts)
    with %UserEvent{} = post <- Context.get(UserEvent, id),
         {:ok, %UserEvent{} = post} <- UserEvents.soft_delete_post(post) do
      Task.async(NotificationsRecords, :delete_notification_by_resource_id, [post.id])
      render(conn, "post.json", %{post: UserEvents.preload_all(post)})
    else
      nil -> render(conn, "post.json", %{error: ["Post not found"]})
      {:error, error} -> render(conn, "post.json", %{error: error})
    end
  end

  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # post_address_components_mapping/1
  #----------------------------------------------------------------------------
#  @doc """
#  Should be moved into a reusable component, like a JSON submodule of a domain object.
#  """
  defp post_address_components_mapping(params) do
    address_components = %{
      place_id: params["place_id"],
      formatted_address: params["formatted_address"],
      url: params["url"]
    }

    address_components_map =
      case is_list(params["address_components"]) do
        true ->
          Map.new(params["address_components"], fn map ->
            {String.to_atom(map["types"]), map["long_name"]}
          end)

        _ ->
          %{}
      end

    Map.merge(address_components, address_components_map)
  end

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :map_posts do
    post("/v1.0/map-posts")
    summary("Map Posts")
    description("Map Posts")
    produces("application/json")

    parameters do
      body :body, Schema.ref(:MapPostsInput), "MapPostsInput", required: true
    end

    response(200, "Ok", Schema.ref(:MapPost))
  end

  def map_posts(conn, %{} = params) do
    page = params["page"] || 1
    page_size = params["page_size"] || 100
    params = Map.merge(params, %{"page" => page, "page_size" => page_size})
    with {:ok, query, _filter_values} <- apply_filters(UserEvent, conn),
    map_posts <- UserEvents.list_events_by(query, params) do
        #  map_posts <- UserEvents.preload_all(posts) do
     render(conn, "map_posts.json", %{map_posts: map_posts})
    end
  end

  def map_posts(conn, params) do
    conn
      |> put_status(400)
      |> json(%{success: false, message: "Some parameter is missing"})
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      Posts:
        swagger_schema do
          title("Posts")
          description("Posts")

          example(%{responseData: %{
            user: %{
              userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              first_name: "First Name",
              last_name: "Last Name",
              user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
              base_url: "https://d1exz3ac7m20xz.cloudfront.net/"
            },
            user_small_image_path: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
            id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
            description: "Here is a description about the post",
            shoutout_images: ["shoutout/a31f1576-a38e-473a-8ca6-64ce28368caf.png",
              "shoutout/63ca14a5-e41a-43a6-8f3c-c09b37e67db7.png"],
            url: "Post Link",
            created_date: "",
            shoutout_latitude: 0.0,
            shoutout_longitude: 0.0,
            is_shared: false,
            is_old_moment: false,
            shoutout_guid: "",
            title: "First Post",
            updated_by: "",
            likes_count: 3,
            comments_count: 3,
            self_like: false,
            comments: %{
              id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              shoutout_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              inserted_at: "",
              updated_at: "",
              description: "Excellent",
              likesCount: 3,
              replies_count: 3,
              replies: [
                %{
                  id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                  comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                  inserted_at: "",
                  updated_at: "",
                  description: "Thanks",
                  likesCount: 4,
                  user: %{
                    userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                    first_name: "First Name",
                    last_name: "Last Name",
                    user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                  }
                },
              ],
              user: %{
                userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                first_name: "First Name",
                last_name: "Last Name",
                user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
              }
            }
          }})
        end,
      CreatePost:
        swagger_schema do
          title("Create New Post")
          description("Create a Post")

          properties do
            description(:string, "Description of post")
            is_deleted(:boolean, "IS_Deleted i.e true or false")
            is_shared(:boolean, "IS_Shared i.e true or false")
            latitude(:float, "location latitude points")
            longitude(:float, "location latitude points")
            is_old_moment(:boolean, "Is Old Moment")
            shoutout_guid(:string, "Shoutout Guid")
            title(:string, "Post title")
            address_components(:map, "Address components array of maps with types and long_name")
            shoutout_type_id(:string, "Shoutout type id")
            #            post_type_id(:string, "Post type id")
            url(:string, "Google map URL")
            formatted_address(:string, "Complete formatted address")
            place_id(:string, "Place ID")
            shoutout_images(:map, "List of images in base64 format")
          end

          example(%{
            description: "Here is description about the post",
            is_shared: false,
            latitude: 0.0,
            longitude: 0.0,
            is_old_moment: false,
            shoutout_guid: "",
            title: "First Post",
            address_components: [],
            shoutout_type_id: "a48b801b-55b7-58ff-b3cc-e0e06a77f28a",
            url: "",
            formatted_address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
            place_id: "",
            shoutout_images: [""]
          })
        end,
      UpdatePost:
        swagger_schema do
          title("Update Post")
          description("Update Post")

          properties do
            description(:string, "Description of post")
            latitude(:float, "location latitude points")
            longitude(:float, "location latitude points")
            title(:string, "Post title")
            address_components(:map, "Address components array of maps with types and long_name")
            url(:string, "Google map URL")
            formatted_address(:string, "Complete formatted address")
            place_id(:string, "Place ID")
            shoutout_images(:map, "List of images in base64 format")
          end

          example(%{
            description: "Here is a description about the post",
            latitude: 0.0,
            longitude: 0.0,
            title: "First Post",
            address_components: [],
            url: "",
            formatted_address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
            place_id: "",
            shoutout_images: []
          })
        end,
      MapPost:
        swagger_schema do
          title("List Of Posts")
          description("List Of Posts")
          example(
            %{
              responseData:
              [%{
                id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                latitude: 33.22,
                longitude: 74.21,
                image: []
              },
              %{
                id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                latitude: 33.22,
                longitude: 74.21,
                image: []
              },
              %{
                id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                latitude: 33.22,
                longitude: 74.21,
                image: []
              }
            ]


            })
        end,
        ListPost:
        swagger_schema do
          title("List Of Posts")
          description("List Of Posts")
          example(
            %{
              responseData:
              %{
                pagination: %{
                  total_pages: 2,
                  page: 1,
                  total_rows: 10
                },
                data: [
                  %{
                    user: %{
                      userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                      first_name: "First Name",
                      last_name: "Last Name",
                      user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                      base_url: "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    user_small_image_path: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                    id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                    description: "Here is a description about the post",
                    shoutout_images: ["shoutout/a31f1576-a38e-473a-8ca6-64ce28368caf.png",
                      "shoutout/63ca14a5-e41a-43a6-8f3c-c09b37e67db7.png"],
                    url: "Post Link",
                    created_date: "",
                    shoutout_latitude: 0.0,
                    shoutout_longitude: 0.0,
                    is_shared: false,
                    is_old_moment: false,
                    shoutout_guid: "",
                    title: "First Post",
                    updated_by: "",
                    likes_count: 3,
                    comments_count: 3,
                    self_like: false,
                    comments: %{
                      id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                      shoutout_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                      inserted_at: "",
                      updated_at: "",
                      description: "Excellent",
                      likesCount: 4,
                      replies_count: 3,
                      replies: [
                        %{
                          id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                          comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                          inserted_at: "",
                          updated_at: "",
                          description: "Thanks",
                          likesCount: 3,
                          user: %{
                            userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                            first_name: "First Name",
                            last_name: "Last Name",
                            user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                          }
                        },
                      ],
                      user: %{
                        userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                        first_name: "First Name",
                        last_name: "Last Name",
                        user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
                      }
                    }
                  }
                ]
              }
            })
        end,

    MapPostsInput:
      swagger_schema do
        title("MapPostsInput")
        description("MapPostsInput")

        properties do
          page(:integer, "Page")
          page_size(:integer, "Page Size")
          event_start_date(:string, "Event Start Date")
          event_end_date(:string, "Event End Date")
          event_start_time(:string, "Event Start Time")
          event_end_time(:string, "Event End Time")
          user_latitude(:float, "User Latitude")
          user_longitude(:float, "User Longitude")
          radius(:float, "Radius")
          distance_unit(:string, "Radius Unit km or miles")
          interest_ids(:map, "List of Interest IDs")
        end

        example(%{
          page: 1,
          page_size: 100,
          event_start_date: "2022-05-09",
          event_end_date: "2022-05-09",
          event_start_time: "11:00:00",
          event_end_time: "23:00:00",
          user_latitude: 31.466750,
          user_longitude: 74.268917,
          radius: 50.5,
          distance_unit: "miles",
          interest_ids: ["64b04a57-c908-4406-969c-778317d712c8", "8ae4578c-9c32-4a08-aef1-12defc664968"],
        })
      end,
      Timeline:
        swagger_schema do
          title("Timeline")
          description("Timeline")

          properties do
            page(:integer, "Page", required: true)
            event_start_date(:string, "Event Start Date")
            event_end_date(:string, "Event End Date")
            age_from(:integer, "Age From")
            age_to(:integer, "Age To")
            gender(:string, "Gender")
            event_start_time(:string, "Event Start Time")
            event_end_time(:string, "Event End Time")
            user_latitude(:float, "User Latitude")
            user_longitude(:float, "User Longitude")
            radius(:float, "Radius")
            distance_unit(:string, "Radius Unit km or miles")
            interest_ids(:map, "List of Interest IDs")
            post_ids(:map, "List of Post IDs")
          end

          example(%{
            page: 1,
            event_start_date: "2022-05-09",
            event_end_date: "2022-05-09",
            event_start_time: "11:00:00",
            event_end_time: "23:00:00",
            user_latitude: 31.466750,
            user_longitude: 74.268917,
            age_to: 50,
            age_from: 10,
            gender: "male",
            radius: 50.5,
            distance_unit: "km",
            interest_ids: ["64b04a57-c908-4406-969c-778317d712c8", "8ae4578c-9c32-4a08-aef1-12defc664968"],
            post_ids: ["64b04a57-c908-4406-969c-778317d712c8", "8ae4578c-9c32-4a08-aef1-12defc664968"]
          })
        end
    }
  end
end
