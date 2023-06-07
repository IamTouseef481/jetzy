#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.AdminPostController do
  @moduledoc """
  API for managing Admin posts.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias ApiWeb.Utils.Common
  alias ApiWeb.Api.V1_0.UserEventController
  alias Data.Context
  alias Data.Schema.{UserEvent, User}
  alias Data.Context.{UserEvents, UserInterests, Users}

  #============================================================================
  # filterable
  #============================================================================

  filterable do
    @options default: ""
    filter base_query(query, _value, conn) do
      query
      |> join(:left, [ue], u in Data.Schema.User, on: ue.user_id == u.id)
      |> order_by([ue], desc: ue.inserted_at)
    end

    filter first_name(query, value, _conn) do
      query
      |> where([_ue, u], ilike(u.first_name, ^"%#{value}%"))
    end

    filter last_name(query, value, _conn) do
      query
      |> where([_ue, u], ilike(u.last_name, ^"%#{value}%"))
    end

    filter interest_name(query, value, _conn) do
      query
      |> join(:left, [ue, _u], i in Data.Schema.Interest, on: i.id == ue.interest_id)
      |> where([_ue, _u, i], ilike(i.interest_name, ^"%#{value}%"))
    end

    filter description(query, value, _conn) do
      query
      |> where([ue, _u], ilike(ue.description, ^"%#{value}%"))
    end

    filter address(query, value, _conn) do
      query
      |> where([ue, _u], ilike(ue.formatted_address, ^"%#{value}%"))
    end

    filter posted_date(query, value, _conn) do
      date = Date.from_iso8601!(value)
      query
      |> where([ue, _u], fragment("?::date", ue.inserted_at) == ^date)
    end

    filter total_likes(query, value, _conn) do
      query
      |> join(:left, [ue, _u], uel in Data.Schema.UserEventLike, on: uel.item_id == ue.id)
      |> group_by([ue, _u, _uel], ue.id)
      |> having([..., uel], count(uel.id) == ^value)
    end
    filter total_comments(query, value, _conn) do
      query
      |> join(:left, [ue, _u], rm in Data.Schema.RoomMessage, on: rm.room_id == ue.room_id)
      |> group_by([ue, _u, _uel], ue.id)
      |> having([..., rm], count(rm.room_id) == ^value)
    end
  end

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/admin/admin-posts"
    summary "Get List Of Posts"
    description "Get List OF Posts"
    produces "application/json"
    parameters do
      first_name :query, :string, "First Name"
      last_name :query, :string, "Last Name"
      description :query, :string, "Description"
      address :query, :string, "Address"
      total_likes :query, :string, "Total Likes"
      total_comments :query, :string, "Total Comments"
      posted_date :query, :string, "Posted Date"
      interest_name :query, :string, "Interest Name"
      page(:query, :integer, "Page no.", required: true)
      page_size(:query, :integer, "Page size.")

    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListPosts)
  end
  @doc """
  Return Post's.
  """
  def index(conn, %{"page" => page} = params) do
    page_size = params["page_size"] || 200
    with {:ok, query, s} <- apply_filters(UserEvent, conn),
       posts <- UserEvents.get_posts_for_admin(query, page, page_size),
       do: render(conn, "posts.json", posts: posts)
  end

  swagger_path :create do
    post "/v1.0/admin/admin-posts"
    summary "Create a Post for users"
    description "Create a Post for users"
    produces "application/json"
    parameters do
      body(:body, Schema.ref(:CreateEvent), "Create an event/post for multiple users on demand" , required: true)
    end
    security [%{Bearer: []}]
    response(200, "Ok", Schema.ref(:CreateListPosts))
  end

  def create(conn, params) do
    user_ids = Users.filter_user_ids(params["user_ids"] || [])
    res = Enum.reduce_while(user_ids ,[] , fn user_id, acc ->
      %User{first_name: first_name, last_name: last_name, id: id} = user = Context.get(User, user_id)
      case UserEventController.create_event(conn, params, first_name, last_name, id) do
        %{user_events: user_events, params: _params} ->
          {:cont, List.insert_at(acc, 0 , user_events)}
        _ -> {:halt, acc}
      end
    end)
    if res != [] do
      render(conn, "admin_posts.json", posts: res|> List.flatten)
      else
      render(conn, "error.json", error: "Something went wrong")
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      ListPosts: swagger_schema do
                     title "List OF Posts"
                     description "List Of Posts"
                     example(%{responseData: %{
                       pagination: %{
                         total_pages: 2,
                         page: 1,
                         total_rows: 10
                       },
                       data: [
                         %{
                           id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                           description: "Outstanding!! Keep It Up.",
                           first_name: "Super",
                           last_name: "Admin",
                           total_likes: 2,
                           total_comments: 3,
                           interst_name: "Beach Bum",
                           posted_date: "21-2222-12",
                           address: "USA Nepall AFG CHINa"
                         },
                         %{
                          id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                          description: "Outstanding!! Keep It Up.",
                          first_name: "ms",
                          last_name: "stiphen",
                          total_likes: 2,
                          total_comments: 3,
                          interst_name: "Beach Bum",
                          posted_date: "21-2222-12",
                          address: "USA Nepall AFG CHINa Pakistan India"
                        },
                        %{
                          id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                          description: "Outstanding!! Keep It Up.",
                          first_name: "john",
                          last_name: "bravo",
                          total_likes: 2,
                          total_comments: 3,
                          interst_name: "Beach Bum",
                          posted_date: "21-2222-12",
                          address: "USA Nepall AFG CHINa"
                        }
                       ]
                     }})
                   end,
      CreateEvent:
        swagger_schema do
          title("Create New Event")
          description("Create a Event")

          properties do
            description(:string, "Description of event")
            latitude(:float, "location latitude points")
            longitude(:float, "location latitude points")
            formatted_address(:string, "Formatted Address")
            event_start_date(:date, "Event Start Date")
            event_end_date(:date, "Event End Date")
            event_end_time(:time, "Event End Time")
            event_start_time(:time, "Event Start Time")
            interest_id(:string, "Interest id")
            event_images(:map, "List of images in base64 format")
            post_tags(:map, "List of tagged user ids")
            user_ids(:map, "List of user_ids for whom you want to create post")
            post_type(:string, "Type of post")
          end

          example(%{
            description: "This is a first description test",
            eventEndDate: "2022-01-10",
            eventStartDate: "2022-01-07",
            eventStartTime: "16:15:47",
            eventEndTime: "22:15:47",
            FormattedAddress: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
            interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
            event_images: [""],
            latitude: 31.5656822,
            longitude: 74.3141829,
            post_tags: ["64b04a57-c908-4406-969c-778317d712c8", "8ae4578c-9c32-4a08-aef1-12defc664968"],
            user_ids: ["4ad5965f-2371-45ee-99ef-44b0665faecf", "66fe7065-04c5-41ea-900d-c30f3f84eab2"],
            post_type: "moment"
          })
        end,
      CreateListPosts: swagger_schema do
        title "List OF Created Posts"
        description "List Of Posts"
        example(%{responseData: %{
          data: [
            %{
              id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              description: "Outstanding!! Keep It Up.",
              first_name: "Super",
              last_name: "Admin",
              total_likes: 2,
              total_comments: 3,
              interst_name: "Beach Bum",
              posted_date: "21-2222-12",
              address: "USA Nepall AFG CHINa"
            },
            %{
              id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              description: "Outstanding!! Keep It Up.",
              first_name: "ms",
              last_name: "stiphen",
              total_likes: 2,
              total_comments: 3,
              interst_name: "Beach Bum",
              posted_date: "21-2222-12",
              address: "USA Nepall AFG CHINa Pakistan India"
            },
            %{
              id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              description: "Outstanding!! Keep It Up.",
              first_name: "john",
              last_name: "bravo",
              total_likes: 2,
              total_comments: 3,
              interst_name: "Beach Bum",
              posted_date: "21-2222-12",
              address: "USA Nepall AFG CHINa"
            }
          ]
        }})
      end
    }
  end
end
