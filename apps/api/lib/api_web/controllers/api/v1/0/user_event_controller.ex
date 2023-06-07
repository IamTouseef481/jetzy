# -------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserEventController do
  @moduledoc """
  Manage User Event Posts.
  """

  # ============================================================================
  # Uses, Requires, Aliases
  # ============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias Data.Context

  alias Data.Context.{
    UserEvents,
    RoomMessages,
    UserBlocks,
    UserInterests,
    NotificationsRecords,
    UserInstalls,
    UserRoles
  }

  alias Data.Schema.{
    UserEvent,
    UserInterest,
    Room,
    RoomUser,
    User,
    UserEventImage,
    Interest,
    UserInstall
  }

  alias JetzyModule.AssetStoreModule, as: AssetStore
  alias ApiWeb.Utils.Common
  alias Api.Workers.PushNotificationEventWorker
  alias Data.Repo
  alias ApiWeb.Filters.InterestsFilter
  alias ApiWeb.Filters.EventCountFilter
  alias ApiWeb.Filters.InterestEventsFilter
  alias Api.Mailer
  # ============================================================================
  # filterable
  # ============================================================================
  filterable do
    #    paginateable(per_page: 20)
    @options default: ""
    filter base_query(query, _value, _conn) do
      query
    end

    @options param: [:latitude, :longitude], cast: :float
    filter filter_by_location(
             query,
             %{latitude: latitude, longitude: longitude},
             _conn
           ) do
      query
      |> order_by(
        [ue],
        fragment(
          #          "ST_DISTANCE(ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography)",
          "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
          ue.latitude,
          ue.longitude,
          ^latitude,
          ^longitude
        )
      )
    end

    @options param: [:event_start_date, :event_end_date]
    filter filter_by_dates(
             query,
             %{event_start_date: event_start_date, event_end_date: event_end_date},
             _conn
           ) do
      start_date = Date.from_iso8601!(event_start_date)
      end_date = Date.from_iso8601!(event_end_date)

      query
      |> where(
        [ue],
        fragment(
          "(? >= ? AND ? <= ?) OR (? >= ? AND ? <= ?)",
          ue.event_start_date,
          ^start_date,
          ue.event_start_date,
          ^end_date,
          ue.event_end_date,
          ^start_date,
          ue.event_end_date,
          ^end_date
        )
      )
    end

    @options param: [:event_start_time, :event_end_time]
    filter filter_by_time(
             query,
             %{event_start_time: event_start_time, event_end_time: event_end_time},
             _conn
           ) do
      start_time = Time.from_iso8601!(event_start_time)
      end_time = Time.from_iso8601!(event_end_time)

      query
      |> where(
        [ue],
        fragment(
          "(? >= ? AND ? <= ?) OR (? >= ? AND ? <= ?)",
          ue.event_start_time,
          ^start_time,
          ue.event_start_time,
          ^end_time,
          ue.event_end_time,
          ^start_time,
          ue.event_end_time,
          ^end_time
        )
      )
    end

    filter interests(query, value, _conn) do
      query
      |> order_by([ue], desc: ue.interest_id in ^Poison.decode!(value))
    end
  end

  # ============================================================================
  # Controller Actions
  # ============================================================================

  # ----------------------------------------------------------------------------
  # index/2
  # ----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/user-events")
    summary("User Events")
    description("User Events")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      event_start_date(:query, :string, "Event Start Date")
      event_end_date(:query, :string, "Event End Date")
      event_start_time(:query, :string, "Event Start Time")
      event_end_time(:query, :string, "Event End Time")
      interests(:query, :map, "Interests")
      latitude(:query, :float, "User Latitude")
      longitude(:query, :float, "User Longitude")
      page(:query, :integer, "Page No.", required: true)
    end

    response(200, "Ok", Schema.ref(:ListEvent))
  end

  @doc """
  List user events.
  """
  def index(conn, params) do
    %{id: user_id, latitude: latitude, longitude: longitude} =
      Guardian.Plug.current_resource(conn)

    user_events_query =
      with {:ok, query, _filter_values} <- apply_filters(UserEvent, conn) do
        query =
          if !is_nil(Map.get(params, "is_event", nil)) do
            query
            |> where([q], not is_nil(q.event_start_date))
            |> where([q], not is_nil(q.event_end_date))
          else
            query
          end

        query =
          query
          |> where([q], is_nil(q.deleted_at))
          |> where(
            [q],
            fragment(
              "(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0",
              q.id
            )
          )
          |> select([q], q)
          |> limit(5)

        query =
          if (!Map.has_key?(params, "latitude") || !Map.has_key?(params, "longitude")) and
               !is_nil(latitude) and !is_nil(longitude) do
            query
            |> order_by(
              [ue],
              fragment(
                "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
                ue.latitude,
                ue.longitude,
                ^latitude,
                ^longitude
              )
            )
          else
            query |> order_by([ue], desc: ue.inserted_at)
          end
      end

    query =
      from(i in Interest)
      |> join(:left, [i], ui in UserInterest,
        on: ui.interest_id == i.id and ui.user_id == ^user_id
      )
      |> join(:inner, [i, _ui], ue in assoc(i, :user_events),
        on:
          is_nil(ue.deleted_at) and
            fragment(
              "(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0",
              ue.id
            )
      )
      |> join(:inner, [_i, _ui, ue], u in assoc(ue, :user), on: u.effective_status == :active)

    with {:ok, query, _filter_values} <- InterestsFilter.apply_filters(query, conn) do
      # actual order by is running from distinct clause.
      interests =
        query
        |> order_by([i], desc: i.is_private)
        |> distinct([i, ui],
          asc:
            fragment(
              "case when ? is not null and ?=true then 'A' when ? is not null then 'B' else 'Z' end",
              ui.user_id,
              i.is_private,
              ui.user_id
            ),
          desc: i.popularity_score,
          asc: i.interest_name,
          asc: i.id
        )
        |> select(
          [i, ui],
          %Interest{
            id: i.id,
            interest_name: i.interest_name,
            description: i.description,
            status: i.status,
            background_colour: i.background_colour,
            image_name: i.image_name,
            is_private: i.is_private,
            small_image_name: i.small_image_name,
            blur_hash: i.blur_hash,
            is_deleted: i.is_deleted,
            is_group_private: i.is_group_private,
            deleted_at: i.deleted_at,
            inserted_at: i.inserted_at,
            updated_at: i.updated_at,
            created_by_id: i.created_by_id,
            ordering_variable:
              fragment(
                "case when ? is not null and ?=true then 'A' when ? is not null then 'B' else 'Z' end as f",
                ui.user_id,
                i.is_private,
                ui.user_id
              )
          }
        )
        |> Repo.paginate(page: params["page"], page_size: 10)

      entries =
        Enum.reduce(interests.entries, [], fn interest, acc ->
          acc ++
            [
              Repo.preload(interest,
                user_events: {user_events_query, [:user, :room, :user_event_images]}
              )
            ]
        end)

      interests = Map.put(interests, :entries, entries)

      render(conn, "index_paging.json", %{
        interests_kw: interests,
        interest_meta_data: interest_events_page_meta_data(entries, conn),
        params: params
      })
    end
  end

  # ----------------------------------------------------------------------------
  # index_for_guest/2
  # ----------------------------------------------------------------------------
  swagger_path :index_for_guest do
    get("/v1.0/guest/user-events")
    summary("User Events")
    description("User Events")
    produces("application/json")

    parameters do
      event_start_date(:query, :string, "Event Start Date")
      event_end_date(:query, :string, "Event End Date")
      event_start_time(:query, :string, "Event Start Time")
      event_end_time(:query, :string, "Event End Time")
      interests(:query, :map, "Interests")
      latitude(:query, :float, "User Latitude")
      longitude(:query, :float, "User Longitude")
      page(:query, :integer, "Page No", required: true)
    end

    response(200, "Ok", Schema.ref(:ListEvent))
  end

  @doc """
  List user events for Guest level user.
  """
  def index_for_guest(conn, params) do
    user_events_query =
      with {:ok, query, _filter_values} <- apply_filters(UserEvent, conn) do
        query
        |> where([q], is_nil(q.deleted_at))
        |> where(
          [q],
          fragment(
            "(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0",
            q.id
          )
        )
        |> select([q], q)
        |> order_by([q], desc: q.inserted_at)
        |> limit(5)
      end

    query =
      from(i in Interest)
      |> join(:inner, [i], ue in assoc(i, :user_events),
        on:
          fragment(
            "? is null and (select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0",
            ue.deleted_at,
            ue.id
          )
      )

    with {:ok, query, _filter_values} <- InterestsFilter.apply_filters(query, conn) do
      interests =
        query
        |> order_by([i], desc: i.popularity_score, asc: i.interest_name)
        |> distinct([i], desc: i.popularity_score, asc: i.interest_name, asc: i.id)
        # |> Ecto.Query.preload([user_events: ^{user_events_query, [:user, :room, :user_event_images, :interest]}])
        |> Repo.paginate(page: params["page"], page_size: 10)

      entries =
        Enum.reduce(interests.entries, [], fn interest, acc ->
          acc ++
            [
              Repo.preload(interest,
                user_events: {user_events_query, [:user, :room, :user_event_images]}
              )
            ]
        end)

      interests = Map.put(interests, :entries, entries)

      render(conn, "index_paging.json", %{
        interests_kw: interests,
        interest_meta_data: interest_events_page_meta_data(entries, conn),
        params: params
      })
    end
  end

  defp interest_events_page_meta_data(interests, conn) do
    ids = Enum.map(interests, fn x -> x.id end)

    with {:ok, query, _filter_values} <- EventCountFilter.apply_filters(UserEvent, conn) do
      stats =
        query
        |> where([q], is_nil(q.deleted_at) and q.interest_id in ^ids)
        |> where(
          [q],
          fragment(
            "(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0",
            q.id
          )
        )
        |> group_by([q], q.interest_id)
        |> select([q], %{interest_id: q.interest_id, cnt: count(q.interest_id)})
        |> Repo.all()

      Enum.reduce(stats, [], fn x, acc ->
        acc ++ [{get_binary_to_string(x.interest_id), x.cnt}]
      end)
    end
  end

  defp get_binary_to_string(nil), do: nil

  defp get_binary_to_string(id) do
    UUID.binary_to_string!(id) |> String.to_atom()
  rescue
    _ -> id |> String.to_atom()
  end

  # ----------------------------------------------------------------------------
  # get_interest_events/2
  # ----------------------------------------------------------------------------
  swagger_path :get_interest_events do
    get("/v1.0/get-interest-events")
    summary("Get Events by Interest ID")
    description("Get data by Interest ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      event_start_date(:query, :string, "Event Start Date")
      event_end_date(:query, :string, "Event End Date")
      event_start_time(:query, :string, "Event Start Time")
      event_end_time(:query, :string, "Event End Time")
      interest_id(:query, :string, "Interest ID", required: true)
      lat(:query, :float, "Latitude")
      long(:query, :float, "Longitude")
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestEvents))
  end

  @doc """
  Get events nearby, for specific interest.
  """
  def get_interest_events(conn, %{"interest_id" => interest_id, "page" => page} = params) do
    %{id: user_id, latitude: latitude, longitude: longitude} =
      Api.Guardian.Plug.current_resource(conn)

    with {:ok, query, _filter_values} <- InterestEventsFilter.apply_filters(UserEvent, conn) do
      query =
        if (!Map.has_key?(params, "lat") || !Map.has_key?(params, "long")) and !is_nil(latitude) and
             !is_nil(longitude) do
          query
          |> order_by(
            [ue],
            fragment(
              "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
              ue.latitude,
              ue.longitude,
              ^latitude,
              ^longitude
            )
          )
        else
          query |> order_by([ue], desc: ue.inserted_at)
        end

      interest_events =
        query
        |> Ecto.Query.preload([:user, :room, :user_event_images, :interest])
        |> Repo.paginate(page: params["page"], page_size: 10)

      render(conn, "user_interest_events.json", %{interest_events: interest_events})
    end
  end

  # ----------------------------------------------------------------------------
  # get_interest_events/2
  # ----------------------------------------------------------------------------
  swagger_path :get_guest_interest_events do
    get("/v1.0/guest/get-interest-events")
    summary("Get Events by Interest ID")
    description("Get data by Interest ID")
    produces("application/json")

    parameters do
      event_start_date(:query, :string, "Event Start Date")
      event_end_date(:query, :string, "Event End Date")
      event_start_time(:query, :string, "Event Start Time")
      event_end_time(:query, :string, "Event End Time")
      interest_id(:query, :string, "Interest ID", required: true)
      lat(:query, :float, "Latitude")
      long(:query, :float, "Longitude")
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestEvents))
  end

  @doc """
  Get events nearby, for specific interest.
  """
  def get_guest_interest_events(conn, %{"interest_id" => interest_id, "page" => page} = params) do
    with {:ok, query, _filter_values} <- InterestEventsFilter.apply_filters(UserEvent, conn) do
      interest_events =
        query
        |> order_by([ue], desc: ue.inserted_at)
        |> Ecto.Query.preload([:user, :room, :user_event_images, :interest])
        |> Repo.paginate(page: params["page"], page_size: 10)

      render(conn, "user_interest_events.json", %{interest_events: interest_events})
    end
  end

  # ----------------------------------------------------------------------------
  # personal_user_events/2
  # ----------------------------------------------------------------------------
  swagger_path :personal_user_events do
    get("/v1.0/personal-user-events")
    summary("Get Event By USER ID")
    description("Get Event By USER ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      user_id(:query, :string, "User ID.")
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:ShowEventByUserID))
  end

  @doc """
  Get events by user.
  """
  def personal_user_events(conn, %{"page" => page} = params) do
    user_id =
      if params["user_id"] do
        params["user_id"]
      else
        %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
        user_id
      end

    user_events = add_user_events_info(user_id, page)
    render(conn, "user_interest_events.json", interest_events: user_events)
  end

  # ----------------------------------------------------------------------------
  # user_event_attendees/2
  # ----------------------------------------------------------------------------
  swagger_path :user_event_attendees do
    get("/v1.0/user-events-attendees/{id}")
    summary("Get Event Attendees By ID")
    description("Get Event Attendees By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Event ID", required: true)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:ShowEventAttendees))
  end

  @doc """
  Get event attendee list.
  """
  def user_event_attendees(conn, %{"id" => id, "page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    case Context.get(UserEvent, id) do
      nil ->
        render(conn, "user_event.json", %{error: ["User event does not exist"]})

      %{group_chat_room_id: id} = user_event ->
        user_event = Context.preload_selective(user_event, [:interest, :user, :user_event_images])
        attendees = RoomMessages.get_event_attendees(user_event.room_id, user_id, page)

        attendees =
          Map.put(
            attendees,
            :entries,
            Enum.map(attendees, fn
              %{user_id: user_id} = attendee ->
                Map.put(
                  attendee,
                  :is_member,
                  not is_nil(RoomMessages.is_member(user_event.group_chat_room_id, user_id))
                )
            end)
          )

        chat_room =
          case UserEvents.get_room(id) do
            nil -> nil
            data -> Map.put(data, :user_event, user_event)
          end

        render(conn, "user_event_attendees.json", %{
          attendees: attendees,
          user_event: user_event,
          chat_room: chat_room,
          current_user_id: user_id
        })
    end
  end

  # ----------------------------------------------------------------------------
  # create/2
  # ----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/user-events")
    summary("Create New Event")
    description("Create a new event with this params. The image is base 64 encoded.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(
        :body,
        Schema.ref(:CreateEvent),
        "Create a new event with this params. The image is base 64 encoded. USER_ID PARAM IS ONLY FOR ADMIN USE",
        required: true
      )
    end

    response(200, "Ok", Schema.ref(:Events))
  end

  @doc """
  Create new user event.
  """

  def create(conn, %{"user_id" => user_id} = param) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)

    with true <- "admin" in UserRoles.get_roles_by_user_id(current_user_id),
         %User{} = user <- Context.get(User, param["user_id"]) do
      case create_event(conn, param, user.first_name, user.last_name, user.id) do
        {:error_insert, error} ->
          render(conn, "user_event.json", %{error: error})

        {:error, error, user_event} ->
          Context.delete(user_event)
          render(conn, "user_event.json", %{error: error})

        event_params ->
          render(conn, "index.json", event_params)
      end
    else
      false ->
        render(conn, "user_event.json", %{error: "You are not authorized"})

      nil ->
        render(conn, "user_event.json", %{error: "User not found"})
    end
  end

  def create(conn, param) do
    %{id: user_id, first_name: first_name, last_name: last_name} =
      Api.Guardian.Plug.current_resource(conn)

    case create_event(conn, param, first_name, last_name, user_id) do
      {:error_insert, error} ->
        render(conn, "user_event.json", %{error: error})

      {:error, error, user_event} ->
        Context.delete(user_event)
        render(conn, "user_event.json", %{error: error})

      event_params ->
        render(conn, "index.json", event_params)
    end
  end

  def send_push_notification_for_post_tagging(
        post_tags_list,
        event_id,
        first_name,
        last_name,
        user_id
      ) do
    Enum.each(post_tags_list, fn post_tags ->
      params_for_post_tagging_push = %{
        "keys" => %{"first_name" => first_name, "last_name" => last_name},
        "event" => "post_tagging",
        "user_id" => post_tags,
        "sender_id" => user_id,
        "type" => "post_tagging",
        "resource_id" => event_id
      }

      ApiWeb.Utils.PushNotification.send_push_notification(params_for_post_tagging_push)
    end)
  end

  # ----------------------------------------------------------------------------
  # show/2
  # ----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/user-events/{id}")
    summary("Get Event By ID")
    description("Get Event By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Event ID", required: true)
    end

    response(200, "Ok", Schema.ref(:ShowEvent))
  end

  @doc """
  Get specific event by id.
  """
  def show(conn, %{"id" => id}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    case Context.get(UserEvent, id)
         |> UserEvents.preload_all() do
      nil ->
        render(conn, "user_event.json", %{error: ["User event does not exist"]})

      %{group_chat_room_id: group_chat_room_id} = user_event ->
        case UserEvents.get_room(group_chat_room_id) do
          nil ->
            render(conn, "user_event.json", %{error: ["User event does not exist"]})

          data ->
            user_chat = Map.put(data, :user_event, user_event)

            render(conn, "show.json", %{
              user_event: user_event,
              user_chat: user_chat,
              current_user_id: user_id
            })
        end
    end
  end

  # ----------------------------------------------------------------------------
  # guest/show_user_events/2
  # ----------------------------------------------------------------------------

  swagger_path :guest_show do
    get("/v1.0/guest/user-events/{id}")
    summary("Get Guest Event By ID")
    description("Get Guest Event By ID")
    produces("application/json")

    parameters do
      id(:path, :string, "Event ID", required: true)
    end

    response(200, "Ok", Schema.ref(:ShowEvent))
  end

  @doc """
  Get specific event by id.
  """
  def guest_show(conn, %{"id" => id}) do
    case Context.get(UserEvent, id)
         |> UserEvents.preload_all() do
      nil ->
        render(conn, "user_event.json", %{error: ["User event does not exist"]})

      %{group_chat_room_id: group_chat_room_id} = user_event ->
        case UserEvents.get_room(group_chat_room_id) do
          nil ->
            render(conn, "user_event.json", %{error: ["User event does not exist"]})

          data ->
            user_chat = Map.put(data, :user_event, user_event)
            render(conn, "show.json", %{user_event: user_event, user_chat: nil})
        end
    end
  end

  # ----------------------------------------------------------------------------
  # update/2
  # ----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/user-events/{id}")
    summary("Update Event")
    description("Update Event")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Event ID", required: true)
      body(:body, Schema.ref(:UpdateEvent), "Update Event Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Events))
  end

  @doc """
  Update specific event by id.
  """
  def update(conn, %{"id" => id} = params) do
    %{id: user_id, first_name: first_name, last_name: last_name} =
      Api.Guardian.Plug.current_resource(conn)

    user_interest_ids = UserInterests.get_user_interest_ids_list(user_id)

    params =
      case AssetStore.upload_if_image_with_thumbnail(params, "image", "user_event") do
        nil ->
          params

        {image, small_image} ->
          Map.merge(params, %{"image" => image, "small_image" => small_image})
      end

    user_event = Context.get(UserEvent, id)

    with %UserEvent{group_chat_room_id: group_chat_room_id, post_tags: post_tags} = user_event <-
           Context.get(UserEvent, id),
         true <-
           user_event.user_id == user_id || "admin" in UserRoles.get_roles_by_user_id(user_id),
         #  params <- update_image(params, user_event),
         #         params <- Map.merge(params, %{"image" => user_image, "small_image" => user_thumb, "blur_hash" => blur_hash}),
         params <- add_or_remove_tags(params, user_event),
         params <-
           ((params["post_email_tags"] || params["remove_post_email_tags"]) &&
              add_or_romove_post_email_tags(params, user_event)) || params,
         _ <- remove_images(params["remove_images"], user_event.id),
         _user_chat <-
           UserEvents.get_room(group_chat_room_id) |> Map.put(:user_event, user_event),
         {:ok, %UserEvent{post_tags: post_tags} = user_event} <-
           Context.update(UserEvent, user_event, params) do
      upload_images_extended(params, user_event)
      # Push notification Params
      push_notification_params = %{
        "keys" => %{"first_name" => first_name, "last_name" => last_name},
        "event" => "events_modified",
        "sender_id" => user_id,
        "type" => "events_modified",
        "resource_id" => user_event.id
      }

      # Send Push notification to tagged users
      if post_tags != [] do
        if params["event_start_time"] || params["event_end_time"] || params["event_start_date"] ||
             params["event_end_date"] ||
             params["latitude"] || params["longitude"] do
          ApiWeb.Utils.PushNotification.send_push_to_users(post_tags, push_notification_params)
        end
      end

      if params["post_email_tags"] do
        Task.start(fn ->
          send_email_of_post_tag(
            params["post_email_tags"],
            first_name <> last_name,
            user_event.id
          )
        end)
      end

      render(conn, "index.json", %{
        user_events: [user_event |> UserEvents.preload_all()],
        params: Map.put(params, "user_interest_ids", user_interest_ids)
      })
    else
      nil -> render(conn, "user_event.json", %{error: ["User event not found"]})
      {:error, error} -> render(conn, "user_event.json", %{error: error})
      false -> render(conn, "user_event.json", %{error: "You are not authorized"})
    end
  end

  def add_or_remove_tags(params, user_event) do
    params =
      if Map.has_key?(params, "add_tags") do
        cond do
          is_nil(user_event.post_tags) ->
            Map.put(params, "post_tags", params["add_tags"])

          true ->
            updated_list = (user_event.post_tags ++ params["add_tags"]) |> Enum.uniq()
            Map.put(params, "post_tags", updated_list)
        end
      else
        params
      end

    if Map.has_key?(params, "remove_tags") do
      cond do
        is_nil(user_event.post_tags) ->
          if Map.has_key?(params, "post_tags") do
            updated_list =
              Enum.reduce(params["remove_tags"], params["post_tags"], fn x, acc ->
                List.delete(acc, x)
              end)
              |> Enum.uniq()

            Map.put(params, "post_tags", updated_list)
          else
            params
          end

        true ->
          if Map.has_key?(params, "post_tags") do
            updated_list =
              Enum.reduce(params["remove_tags"], params["post_tags"], fn x, acc ->
                List.delete(acc, x)
              end)
              |> Enum.uniq()

            Map.put(params, "post_tags", updated_list)
          else
            updated_list =
              Enum.reduce(params["remove_tags"], user_event.post_tags, fn x, acc ->
                List.delete(acc, x)
              end)
              |> Enum.uniq()

            Map.put(params, "post_tags", updated_list)
          end
      end
    else
      params
    end
  end

  def update_image(params, user_event) do
    case AssetStore.upload_if_image_extended(params, "image", "user_event", user_event) do
      nil ->
        params

      {user_image, user_thumb, blur_hash} ->
        Map.merge(params, %{
          "image" => user_image,
          "small_image" => user_thumb,
          "blur_hash" => blur_hash
        })
    end
  end

  defp remove_images(nil, event_id), do: :ok

  defp remove_images(images, event_id) do
    Enum.each(images, fn image ->
      case Context.get_by(UserEventImage, id: image, user_event_id: event_id) do
        nil ->
          :ok

        %UserEventImage{} = event_image ->
          Context.update(UserEventImage, event_image, %{deleted_at: DateTime.utc_now()})

        _ ->
          :ok
      end
    end)
  end

  # ----------------------------------------------------------------------------
  # delete/2
  # ----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/user-events/{id}")
    summary("Delete Event")
    description("Delete Event")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Event ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Events))
  end

  @doc """
  Delete specific event by id.
  """
  def delete(conn, %{"id" => id}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    with %UserEvent{} = user_event <- Context.get(UserEvent, id),
         true <-
           user_event.user_id == user_id || "admin" in UserRoles.get_roles_by_user_id(user_id),
         {:ok, %UserEvent{group_chat_room_id: group_chat_room_id} = user_event} <-
           Context.delete(user_event),
         user_chat <- UserEvents.get_room(group_chat_room_id) |> Map.put(:user_event, user_event) do
      Task.async(NotificationsRecords, :delete_notification_by_resource_id, [user_event.id])

      render(conn, "show.json", %{
        user_event: user_event |> UserEvents.preload_all(),
        room_messages: [],
        user_chat: user_chat,
        current_user_id: user_id
      })
    else
      nil -> render(conn, "user_event.json", %{error: ["User event not found"]})
      {:error, error} -> render(conn, "user_event.json", %{error: error})
      false -> render(conn, "user_event.json", %{error: "You are not authorized"})
    end
  end

  # ----------------------------------------------------------------------------
  # user_event_add_attendee/2
  # ----------------------------------------------------------------------------
  swagger_path :user_event_add_attendee do
    post("/v1.0/user-events-add-attendee")
    summary("Add a user to an event")
    description("It will Add new attendee to group chat from params")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:AddEventAttendee), "Add new attendee to group chat from params",
        required: true
      )
    end

    response(200, "Ok", %{message: "", success: true})
  end

  @doc """
  Add attendee to event.
  """
  def user_event_add_attendee(
        conn,
        %{"user_event_id" => user_event_id, "user_id" => user_id} = _params
      ) do
    %{id: current_user_id, first_name: first_name, last_name: last_name} =
      Api.Guardian.Plug.current_resource(conn)

    blocked_user_ids = UserBlocks.get_blocked_user_ids(current_user_id)

    with true <- user_id not in blocked_user_ids,
         %{
           is_deleted: is_deleted,
           is_deactivated: is_deactivated,
           is_self_deactivated: is_self_deactivated
         } <- Context.get(User, user_id),
         false <- is_deleted or is_deactivated or is_self_deactivated,
         %UserEvent{} = user_event <- Context.get(UserEvent, user_event_id),
         nil <-
           Context.get_by(RoomUser, room_id: user_event.group_chat_room_id, user_id: user_id),
         {:ok, _room_user} <-
           Context.create(RoomUser, %{user_id: user_id, room_id: user_event.group_chat_room_id}) do
      push_notification_params = %{
        "keys" => %{"first_name" => first_name, "last_name" => last_name},
        "event" => "event_invitation_from_friend",
        "user_id" => user_id,
        "sender_id" => current_user_id,
        "type" => "event_invitation_from_friend",
        "resource_id" => user_event.id
      }

      ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
      render(conn, "message.json", %{message: "Your group request is successfully sent"})
    else
      false ->
        render(conn, "error.json", %{error: "The user is blocked"})

      nil ->
        render(conn, "error.json", %{error: "The user or user event does not exist"})

      true ->
        render(conn, "error.json", %{error: "The user is either deactivated or deleted"})

      %RoomUser{} ->
        render(conn, "error.json", %{error: "Attendee already added to the room"})

      {:error, changeset} ->
        render(conn, "error.json", %{
          error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)
        })

      _ ->
        render(conn, "error.json", %{error: "Something went wrong"})
    end
  end

  # ----------------------------------------------------------------------------
  # delete_event_attendee/2
  # ----------------------------------------------------------------------------
  swagger_path :delete_event_attendee do
    PhoenixSwagger.Path.delete("/v1.0/remove-event-attendee")
    summary("Delete Event Attendee")
    description("Delete Event Attendee")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      event_id(:query, :string, "Event ID", required: true)
      user_id(:query, :string, "User ID", required: true)
    end

    response(200, "Ok", Schema.ref(:ShowEventByUserID))
  end

  @doc """
  Remove attendee from event.
  """
  def delete_event_attendee(conn, %{"event_id" => event_id, "user_id" => user_id}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)

    with %Data.Schema.RoomUser{} = user_event <- UserEvents.remove_attendee(event_id, user_id),
         {:ok, %Data.Schema.RoomUser{}} <- Context.delete(user_event),
         event <- Context.get(UserEvent, event_id),
         true <- event.user_id == current_user_id do
      Task.async(NotificationsRecords, :delete_notification_by_receiver_and_resource_id, [
        user_id,
        user_event.id
      ])

      render(conn, "user_event.json", %{error: ["User event attendee removed successfully"]})
    else
      false -> render(conn, "user_event.json", %{error: ["User event not found"]})
      nil -> render(conn, "user_event.json", %{error: ["User event not found"]})
      {:error, error} -> render(conn, "user_event.json", %{error: error})
    end
  end

  # ============================================================================
  # Internal Methods
  # ============================================================================

  # ----------------------------------------------------------------------------
  # add_user_events_info/1
  # ----------------------------------------------------------------------------
  def add_user_events_info(id, page) do
    user_events = UserEvents.get_events_by_user_id(id, page)

    result =
      Enum.map(user_events.entries, fn %{room_id: room_id, group_chat_room_id: group_chat_room_id} =
                                         user_event ->
        Map.merge(user_event, %{
          attendees:
            room_id && group_chat_room_id &&
              UserEvents.get_event_attendees(room_id, group_chat_room_id, id, page)
        })
      end)

    Map.put(user_events, :entries, result)
  end

  # ----------------------------------------------------------------------------
  # upload_images/2
  # ----------------------------------------------------------------------------
  defp upload_images_extended(params, user_event) do
    case AssetStore.upload_if_image_with_thumbnail(params, "event_images", "user_event") do
      nil ->
        nil

      img_urls when is_list(img_urls) ->
        Enum.map(img_urls, fn
          nil ->
            nil

          {img_url, thumbnail, blur_hash} ->
            Context.create(UserEventImage, %{
              image: img_url,
              user_event_id: user_event.id,
              small_image: thumbnail,
              blur_hash: blur_hash
            })

          {img_url, thumbnail} ->
            Context.create(UserEventImage, %{
              image: img_url,
              user_event_id: user_event.id,
              small_image: thumbnail,
              blur_hash: nil
            })
        end)

      [] ->
        []

      _ ->
        nil
    end
  end

  # ----------------------------------------------------------------------------
  # upload_images/2
  # ----------------------------------------------------------------------------
  defp upload_images(params, user_event) do
    case AssetStore.upload_if_image_with_thumbnail(params, "event_images", "user_event") do
      nil ->
        nil

      img_urls when is_list(img_urls) ->
        Enum.map(img_urls, fn
          nil ->
            nil

          {img_url, thumbnail} ->
            Context.create(UserEventImage, %{
              image: img_url,
              user_event_id: user_event.id,
              small_image: thumbnail
            })
        end)

      [] ->
        []

      _ ->
        nil
    end
  end

  defp make_shareable_link(user_event) do
    Task.start(fn ->
      sle = Common.generate_url("event", user_event.id)
      slf = Common.generate_url("feed", user_event.id)
      cs = %{shareable_link_event: sle, shareable_link_feed: slf}

      user_event
      |> UserEvent.changeset(cs)
      |> Repo.insert_or_update()
    end)
  end

  def create_event(conn, param, first_name, last_name, user_id) do
    first_name = if is_nil(first_name), do: "", else: first_name
    last_name = if is_nil(last_name), do: "", else: last_name

    user_interest_ids = UserInterests.get_user_interest_ids_list(user_id)

    param =
      (param["post_email_tags"] &&
         Map.put(param, "post_email_tags", Enum.uniq(param["post_email_tags"]))) || param

    params =
      param
      |> Map.put(
        "event_start_date",
        Common.convert_date_string_to_date_format(param["event_start_date"])
      )
      |> Map.put(
        "event_end_date",
        Common.convert_date_string_to_date_format(param["event_end_date"])
      )
      |> Map.put(
        "event_start_time",
        Common.convert_time_string_to_time_format(param["event_start_time"])
      )
      |> Map.put(
        "event_end_time",
        Common.convert_time_string_to_time_format(param["event_end_time"])
      )

    #    params = Map.merge(params, %{"image" => AssetStore.upload_if_image(params, "image", "user_event")})

    case Context.create(UserEvent, Map.put(params, "user_id", user_id)) do
      {:ok, user_event} ->
        with {:ok, room} <- Context.create(Room, %{room_type: "event_comments"}),
             {:ok, _room_users} <-
               Context.create(RoomUser, %{room_id: room.id, user_id: user_id}),
             {:ok, group_chat_room} <- Context.create(Room, %{room_type: "event_chat"}),
             {:ok, _group_chat_room_users} <-
               Context.create(RoomUser, %{room_id: group_chat_room.id, user_id: user_id}),
             {:ok, %UserEvent{} = user_event} <-
               Context.update(UserEvent, user_event, %{
                 room_id: room.id,
                 group_chat_room_id: group_chat_room.id
               }),
             _user_chat <-
               UserEvents.get_room(group_chat_room.id) |> Map.put(:user_event, user_event) do
          make_shareable_link(user_event)
          upload_images_extended(params, user_event)

          if Map.has_key?(params, "post_tags") do
            send_push_notification_for_post_tagging(
              params["post_tags"],
              user_event.id,
              first_name,
              last_name,
              user_id
            )
          end

          reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b36"

          push_notification_params_while_creating = %{
            "keys" => %{date: param["event_start_date"]},
            "event" => "events_by_me",
            "user_id" => user_id,
            "sender_id" => user_id,
            "type" => "events_by_me",
            "resource_id" => user_event.id
          }

          ApiWeb.Utils.PushNotification.send_push_notification(
            push_notification_params_while_creating
          )

          ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)
          ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, group_chat_room)
          ApiWeb.Utils.Common.update_points(user_id, :create_a_event)

          Jetzy.Module.Telemetry.Analytics.post_created(conn, user_id, user_event)

          case params["event_start_date"] do
            date when date.__struct__ == Date ->
              event_start_date = (Date.diff(date, Date.utc_today()) - 1) * 86400

              push_notification_params_for_event_coming = %{
                "keys" => %{event_name: user_event.description},
                "event" => "events_coming_soon",
                "user_id" => user_id,
                "schedule_time" => event_start_date,
                "worker_name" => PushNotificationEventWorker,
                "sender_id" => user_id,
                "type" => "events_coming_soon",
                "resource_id" => user_event.id
              }

              ApiWeb.Utils.PushNotification.schedule_push_notification(
                push_notification_params_for_event_coming
              )

            _ ->
              nil
          end

          if params["post_email_tags"] do
            Task.start(fn ->
              send_email_of_post_tag(
                params["post_email_tags"],
                first_name <> last_name,
                Context.get(UserEvent, user_event.id)
              )
            end)
          end

          %{
            user_events: [user_event |> UserEvents.preload_all()],
            params: Map.put(params, "user_interest_ids", user_interest_ids)
          }
        else
          {:error, error} ->
            {:error, :error, user_event}
        end

      {:error, error} ->
        {:error_insert, error}
    end
  end

  defp send_email_of_post_tag(emails, sender_name, user_event) do
    Enum.each(emails, fn email ->
      params = %{
        subject: "#{sender_name} tagged you in a post",
        notification: "#{sender_name} tagged you in a post",
        template_name: "post_tag_email.html",
        event_link: user_event.shareable_link_event,
        feed_event_link: user_event.shareable_link_feed
      }

      Mailer.send_email_of_post_tagging(%{email: email, first_name: ""}, params)
    end)
  end

  defp add_or_romove_post_email_tags(params, user_event) do
    post_email_tags = user_event.post_email_tags || []

    post_email_tags =
      if(params["remove_post_email_tags"]) do
        (post_email_tags -- params["remove_post_email_tags"]) |> Enum.uniq()
      else
        post_email_tags
      end

    post_email_tags =
      if(params["post_email_tags"]) do
        new_list = (post_email_tags ++ params["post_email_tags"]) |> Enum.uniq()
        Map.put(params, "post_email_tags", new_list)
      else
        post_email_tags
      end

    Map.put(params, "post_email_tag", post_email_tags)
  end


  #-------------------------------------------------------------------------
  # events
  #-------------------------------------------------------------------------
  def events(conn, params) do
    response = UserEvents.get_events(params)
    render(conn, "events.json", %{})
  end

  # ========================================================================
  # Swagger Definition
  # ========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      Events:
        swagger_schema do
          title("Events")
          description("Events")

          example(%{
            response_data: %{
              description: "This is a first description test",
              eventEndDate: "2022-01-10",
              eventStartDate: "2022-01-07",
              eventStartTime: "16:15:47",
              eventEndTime: "22:15:47",
              FormattedAddress:
                "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
              id: "d822b84d-a76a-446a-9daa-ab85fe537fea",
              interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
              interestName: "Winter Sports",
              userEventImages: [
                %{
                  id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ],
              latitude: 31.5656822,
              longitude: 74.3141829,
              room_id: "",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              user: %{
                firstName: "test",
                lastName: "user",
                userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
              },
              privateChatRoom: %{
                userEvent: %{
                  user: %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  },
                  roomId: "70086df1-f42f-4fc7-bdf7-5dbffc84deb9",
                  longitude: 74.3141829,
                  latitude: 31.5656822,
                  interestName: "Winter Sports",
                  interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                  userEventImages: [
                    %{
                      id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  id: "5855e460-2e73-46a6-95bd-18bae67d89ac",
                  FormattedAddress:
                    "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                  eventStartTime: "16:15:47",
                  eventStartDate: "2022-01-07",
                  eventEndTime: "22:15:47",
                  eventEndDate: "2022-01-10",
                  eventAttendees: [],
                  description: "This is a first description test",
                  baseUrl: nil
                },
                roomUsers: [
                  %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  }
                ],
                roomType: "event_chat",
                roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                lastMessage: nil
              }
            }
          })
        end,
      ShowEvent:
        swagger_schema do
          title("Event Details")
          description("Event Details")

          example(%{
            response_data: %{
              userEvent: %{
                description: "This is a first description test",
                eventEndDate: "2022-01-10",
                eventStartDate: "2022-01-07",
                eventStartTime: "16:15:47",
                eventEndTime: "22:15:47",
                FormattedAddress:
                  "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                id: "d822b84d-a76a-446a-9daa-ab85fe537fea",
                interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                interestName: "Winter Sports",
                userEventImages: [
                  %{
                    id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                ],
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                latitude: 31.5656822,
                longitude: 74.3141829,
                room_id: "",
                user: %{
                  firstName: "test",
                  lastName: "user",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              },
              privateChatRoom: %{
                userEvent: %{
                  user: %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  },
                  roomId: "70086df1-f42f-4fc7-bdf7-5dbffc84deb9",
                  longitude: 74.3141829,
                  latitude: 31.5656822,
                  interestName: "Winter Sports",
                  interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                  userEventImages: [
                    %{
                      id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  id: "5855e460-2e73-46a6-95bd-18bae67d89ac",
                  FormattedAddress:
                    "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                  eventStartTime: "16:15:47",
                  eventStartDate: "2022-01-07",
                  eventEndTime: "22:15:47",
                  eventEndDate: "2022-01-10",
                  eventAttendees: [],
                  description: "This is a first description test",
                  baseUrl: nil
                },
                roomUsers: [
                  %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  }
                ],
                roomType: "event_chat",
                roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                lastMessage: nil
              }
            }
          })
        end,
      ShowEventAttendees:
        swagger_schema do
          title("Event Attendees")
          description("Event Attendees")

          example(%{
            response_data: %{
              userEvent: %{
                description: "This is a first description test",
                eventEndDate: "2022-01-10",
                eventStartDate: "2022-01-07",
                eventStartTime: "16:15:47",
                eventEndTime: "22:15:47",
                FormattedAddress:
                  "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                id: "d822b84d-a76a-446a-9daa-ab85fe537fea",
                interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                interestName: "Winter Sports",
                userEventImages: [
                  %{
                    id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                ],
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                latitude: 31.5656822,
                longitude: 74.3141829,
                eventAttendees: [],
                room_id: "",
                user: %{
                  firstName: "test",
                  lastName: "user",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              },
              data: [
                %{
                  firstName: "test",
                  lastName: "user",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                  isMember: true,
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  firstName: "test",
                  lastName: "user",
                  userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
                  userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                  isMember: false,
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ],
              privateChatRoom: %{
                userEvent: %{
                  user: %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  },
                  roomId: "70086df1-f42f-4fc7-bdf7-5dbffc84deb9",
                  longitude: 74.3141829,
                  latitude: 31.5656822,
                  interestName: "Winter Sports",
                  interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                  userEventImages: [
                    %{
                      id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  id: "5855e460-2e73-46a6-95bd-18bae67d89ac",
                  FormattedAddress:
                    "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                  eventStartTime: "16:15:47",
                  eventStartDate: "2022-01-07",
                  eventEndTime: "22:15:47",
                  eventEndDate: "2022-01-10",
                  eventAttendees: [],
                  description: "This is a first description test",
                  baseUrl: nil
                },
                roomUsers: [
                  %{
                    userImage: nil,
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                    lastName: "Admin",
                    firstName: "Super",
                    baseUrl: nil
                  }
                ],
                roomType: "event_chat",
                roomId: "73914fed-d79e-4a01-b9a8-79b59737158c",
                lastMessage: nil
              }
            }
          })
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
            post_email_tags(:map, "List of emails to tag")
            user_id(:string, "User id (only for admin use)")
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
            post_tags: [
              "64b04a57-c908-4406-969c-778317d712c8",
              "8ae4578c-9c32-4a08-aef1-12defc664968"
            ],
            post_email_tags: ["abc@jetzy.com", "xyz@gmail.com"],
            user_id: "64b04a57-c908-4406-969c-778317d712c8 (only for admin)"
          })
        end,
      UpdateEvent:
        swagger_schema do
          title("Update Event")
          description("Update Event")

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
            event_images(:map, "List of images we want to add in base64 format")
            remove_tags(:map, "List of tags we want to remove")
            add_tags(:map, "List of tags we want to add")
            remove_images(:map, "List of images we want to remove in base64 format")
            post_email_tags(:map, "List of emails to tag")
            remove_post_email_tags(:map, "List of emails to remove from tags")
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
            remove_tags: [""],
            add_tags: [""],
            remove_images: [""],
            post_email_tags: ["abc@jetzy.com", "xyz@gmail.com"],
            remove_post_email_tags: ["mno@jetzy.com", "abd@gmail.com"]
          })
        end,
      AddEventAttendee:
        swagger_schema do
          title("Add New Event Attendee to Group Chat")
          description("Add New Event Attendee to Group Chat")

          properties do
            user_event_id(:string, "User event ID")
            user_id(:string, "User ID")
          end

          example(%{
            user_event_id: "75e19e13-8ec1-4024-b454-4e1313d5cfbf",
            user_id: "75e19e13-8ec1-4024-b454-4e1313d5cfbf"
          })
        end,
      ShowEventByUserID:
        swagger_schema do
          title("List Of Events By User ID")
          description("List Of Events By User ID")

          example(%{
            ResponseData: [
              %{
                pagination: %{
                  totalRows: 7,
                  totalPages: 2,
                  page: 1
                },
                data: [
                  %{
                    description: "Event testing",
                    eventEndDate: "2018-08-02",
                    eventEndTime: "13:00:00",
                    eventStartDate: "2018-08-02",
                    eventStartTime: "08:00:00",
                    FormattedAddress: "ajsjsjdkds",
                    id: "3075bfea-63cc-11ec-90d6-0242ac120003",
                    userEventImages: [
                      %{
                        id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ],
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    interestId: "0f9165b8-9b72-4551-9e52-f69a61bd8e97",
                    interestName: "Movie Buff",
                    latitude: 687.0,
                    longitude: 345.0,
                    roomId: "9577ce5c-63cb-11ec-90d6-0242ac120003",
                    user: %{
                      firstName: "Super",
                      lastName: "Admin",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    eventAttendees: [
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      },
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ]
                  },
                  %{
                    description: "Event testing",
                    eventEndDate: "2018-08-02",
                    eventEndTime: "13:00:00",
                    eventStartDate: "2018-08-02",
                    eventStartTime: "08:00:00",
                    FormattedAddress: "ajsjsjdkds",
                    id: "3075bfea-63cc-11ec-90d6-0242ac120003",
                    userEventImages: [
                      %{
                        id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ],
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    interestId: "0f9165b8-9b72-4551-9e52-f69a61bd8e97",
                    interestName: "Movie Buff",
                    latitude: 687.0,
                    longitude: 345.0,
                    roomId: "9577ce5c-63cb-11ec-90d6-0242ac120003",
                    user: %{
                      firstName: "Super",
                      lastName: "Admin",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    eventAttendees: [
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      },
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ]
                  }
                ]
              }
            ]
          })
        end,
      ListEvent:
        swagger_schema do
          title("List Of Events")
          description("List Of Events")

          example(%{
            response_data: [
              %{
                interestEvents: [
                  %{
                    description: "This is a first description test",
                    eventEndDate: "2022-01-10",
                    eventStartDate: "2022-01-07",
                    eventStartTime: "16:15:47",
                    eventEndTime: "22:15:47",
                    FormattedAddress:
                      "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                    id: "d822b84d-a76a-446a-9daa-ab85fe537fec",
                    interestId: "f6c16a76-3896-43b1-941f-1b11bea24d81",
                    interestName: "Photographer",
                    userEventImages: [
                      %{
                        id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ],
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    latitude: 31.5656822,
                    longitude: 74.3141829,
                    room_id: "",
                    user: %{
                      firstName: "test",
                      lastName: "user",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  },
                  %{
                    description: "This is a first description test",
                    eventEndDate: "2022-01-10",
                    eventStartDate: "2022-01-07",
                    eventStartTime: "16:15:47",
                    eventEndTime: "22:15:47",
                    FormattedAddress:
                      "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                    id: "d822b84d-a76a-446a-9daa-ab85fe537feb",
                    interestId: "f6c16a76-3896-43b1-941f-1b11bea24d81",
                    interestName: "Photographer",
                    userEventImages: [
                      %{
                        id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ],
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    latitude: 31.5656822,
                    longitude: 74.3141829,
                    room_id: "",
                    user: %{
                      firstName: "test",
                      lastName: "user",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  }
                ],
                interestId: "f6c16a76-3896-43b1-941f-1b11bea24d81",
                interestName: "Photographer",
                lastInterestCreatedBefore: "10 minutes",
                trending: false
              },
              %{
                interestEvents: [
                  %{
                    description: "This is a first description test",
                    eventEndDate: "2022-01-10",
                    eventStartDate: "2022-01-07",
                    eventStartTime: "16:15:47",
                    eventEndTime: "22:15:47",
                    FormattedAddress:
                      "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                    id: "d822b84d-a76a-446a-9daa-ab85fe537fea",
                    interestId: "c2bedfc2-7db3-4e28-bf87-dd2de088526d",
                    interestName: "Winter Sports",
                    userEventImages: [
                      %{
                        id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        image: "user_event/b3e280a5-7808-41fb-8c64-8ee46273ccf4.png",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                      }
                    ],
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    latitude: 31.5656822,
                    longitude: 74.3141829,
                    room_id: "",
                    user: %{
                      firstName: "test",
                      lastName: "user",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  }
                ],
                interestId: "f6c16a76-3896-43b1-941f-1b11bea24d81",
                interestName: "Winter Sports",
                lastInterestCreatedBefore: "2 minutes",
                trending: false
              }
            ]
          })
        end
    }
  end
end
