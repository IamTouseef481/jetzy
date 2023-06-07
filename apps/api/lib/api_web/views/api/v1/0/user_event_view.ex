defmodule ApiWeb.Api.V1_0.UserEventView do
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.{UserEventView}
  alias Data.Context.{UserEvents}
  alias ApiWeb.Utils.Common
  alias Data.Context.UserEventLikes

  def render("index_paging.json", %{interests_kw: interests_kw, interest_meta_data: interest_meta_data} = data) do

    events_data = Enum.map(interests_kw.entries, fn interest ->
      total_entries = case interest_meta_data[String.to_atom(interest.id)] do
        nil -> 0
        total -> total
      end

      
      #TODO - apply some logic and send exact value instead hard coded value
      trending = false
      last_interest_created_before =
        DateTime.diff(DateTime.utc_now(), List.first(interest.user_events).inserted_at)
        |> Common.convert_seconds_to_readable_string()
      # fill interest name in all user events
      user_events = Enum.map(interest.user_events, fn x -> Map.put(x, :interest_name, interest.interest_name) end)
      %{
        interest_id: interest.id,
        last_interest_created_before: last_interest_created_before,
        trending: trending,
        interest_name: interest.interest_name,
        events_pagination: %{total_rows: total_entries, total_pages: ceil(total_entries / 5), page: 1},
        interest_events: render_many(user_events, UserEventView, "user_event.json")
      }
    end)
    %{
      data: events_data,
      pagination:
      %{
        total_rows: interests_kw.total_entries,
        page: interests_kw.page_number,
        total_pages: interests_kw.total_pages
      }
    }
  end

  def render("index.json", %{user_events: user_events} = data) do
    user_events =
      user_events
      |> Enum.group_by(fn
        %{interest: %{interest_name: interest_name}} -> interest_name
        _ -> nil
      end)

    params = if Map.has_key?(data, :params), do: data.params, else: nil
    Map.merge(user_events, %{"params" => params})
    |> render_one(UserEventView, "interest_events.json")
  end

  def render("interest_events.json", user_events) do
    events = Enum.map(Map.delete(user_events.user_event, "params"), fn {interest_name, user_events} ->
      #TODO - apply some logic and send exact value instead hard coded value
      trending = false
      last_interest_created_before =
        DateTime.diff(DateTime.utc_now(), List.first(user_events).inserted_at)
        |> Common.convert_seconds_to_readable_string()
      %{
        interest_id: Enum.at(user_events, 0).interest_id,
        last_interest_created_before: last_interest_created_before,
        trending: trending,
        interest_name: interest_name,
        interest_events: render_many(user_events, UserEventView, "user_event.json")
      }
    end)
    |> Enum.sort_by(& &1.interest_id in Common.popular_interest_ids(), :desc)
    if user_events.user_event["params"]["interests"] do
      ids = Poison.decode!(user_events.user_event["params"]["interests"])
      Enum.sort_by(events, & &1.interest_id in ids, :desc)
    else
      user_interest_ids = user_events.user_event["params"]["user_interest_ids"]
      if user_interest_ids do
        Enum.sort_by(events, & &1.interest_id in user_interest_ids, :desc)
      else
        events
      end
      |> Enum.sort_by(fn event -> not is_nil(event.interest_id) end, :desc)
    end
  end

  def render("show.json", %{user_event: user_event, user_chat: chat_room} = data) do
    private_chat_room = if is_nil(chat_room) do
      nil
    else
#      render_one(chat_room, UserChatView, "user_room.json" , as: :user_room)
       ApiWeb.Api.V1_0.UserChatView.render("user_room.json", %{user_room: chat_room, current_user_id: data[:current_user_id]})
    end
    event = render_one(user_event, UserEventView, "user_event.json")
    %{user_event: event, private_chat_room: private_chat_room}
#      Map.merge(event, %{event_comments: %{data: room_data, pagination: page_data}})}
  end

  def render("user_event_message.json", %{message: message}) do
    message = Data.Context.RoomMessages.preload_all(message)
    %{
      message_id: message.id,
      message: message.message,
      message_images: render_many(message.message_images, UserEventView, "message_image.json", as: :message_image),
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: message.sender}),
    }
  end

  def render("message_image.json", %{message_image: message_image}) do
    message_image.image
  end

  def render("user_interest_events.json", %{interest_events: interest_events}) do
    user_events = render_many(interest_events, UserEventView, "user_event.json", as: :user_event)
    page_data = %{
      total_rows: interest_events.total_entries,
      page: interest_events.page_number,
      total_pages: interest_events.total_pages
    }
    %{data: user_events, pagination: page_data}
  end

  def render("user_event.json", %{user_event: user_event}) do

    event_attendees = case user_event do
      %{attendees: %Scrivener.Page{entries: event_attendees}} when is_list(event_attendees) -> event_attendees
      _ -> []
    end
    interest_name = if(!is_nil(user_event.interest_name)) do
      user_event.interest_name
    else
      user_event.interest && user_event.interest.interest_name
    end
    tags =
    user_event.post_tags &&
      ApiWeb.Api.V1_0.UserView.render("users.json",
        %{users: UserEvents.user_for_post_tags(user_event.post_tags)})
    %{
      id: user_event.id,
      description: user_event.description,
      latitude: user_event.latitude,
      likes_count: UserEventLikes.get_likes_count_by_item_id(user_event.id),
      longitude: user_event.longitude,
      formatted_address: user_event.formatted_address,
      event_start_date: user_event.event_start_date,
      event_end_date: user_event.event_end_date,
      event_start_time: user_event.event_start_time,
      event_end_time: user_event.event_end_time,
      interest_id: user_event.interest_id,
      interest_name: interest_name,
      post_tags: tags,
      shareable_link_event: user_event.shareable_link_event,
      shareable_link_feed: user_event.shareable_link_feed,
      user_event_images: user_event.user_event_images == [] &&  [%{id: nil, image: user_event.user.image_name, image_thumbnail: user_event.user.small_image_name}] ||
        render_many(user_event.user_event_images, UserEventView, "user_event_images.json", as: :user_event_image),
      room_id: user_event.room_id,
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user_event.user}),
      event_attendees: render_many(event_attendees, UserEventView, "user_event_attendee.json", as: :attendee),
      post_email_tags: user_event.post_email_tags
    }
  end

  def render("user_event_images.json", %{user_event_image: user_event_image}) do
    %{
      id: user_event_image.id,
      image: user_event_image.image,
      image_thumbnail: user_event_image.small_image,
      blur_hash: user_event_image.blur_hash,
    }
  end
  def render("events_interests.json", %{interest_events: interest_events}) do
    render_many(interest_events, UserEventView, "events_interest.json")
  end

  def render("events_interest.json", %{interest_event: interest_event}) do
    %{
      id: interest_event.id,
      description: interest_event.description,
      latitude: interest_event.latitude,
      longitude: interest_event.longitude,
      formatted_address: interest_event.formatted_address,
      event_start_date: interest_event.event_start_date,
      event_end_date: interest_event.event_end_date,
      event_start_time: interest_event.event_start_time,
      event_end_time: interest_event.event_end_time,
      interest_id: interest_event.interest_id,
      image: interest_event.image
    }
  end
  def render("user_event.json", %{error: error}) do
    %{errors: error}
  end

  def render("user_event_attendees.json", %{attendees: attendees, user_event: user_event, chat_room: chat_room} = data) do
    page_data = %{
      total_rows: attendees.total_entries,
      page: attendees.page_number,
      total_pages: attendees.total_pages
    }
    event_attendees_data = render_many(attendees, UserEventView, "user_event_attendee.json", as: :attendee)
    private_chat_room = if is_nil(chat_room) do
      nil
    else
#        render_one(chat_room, UserChatView, "user_room.json" , as: :user_room)
      ApiWeb.Api.V1_0.UserChatView.render("user_room.json", %{user_room: chat_room, current_user_id: data[:current_user_id]})
    end
    %{
      user_event: render_one(user_event, UserEventView, "user_event.json"),
      data: event_attendees_data,
      pagination: page_data,
      private_chat_room: private_chat_room
    }
  end

  def render("user_event_attendee.json", %{attendee: attendee}) do
    %{
      user_id: attendee.user_id,
      first_name: attendee && attendee.first_name,
      last_name: attendee && attendee.last_name,
      user_image: attendee && attendee.image_name,
      is_member: attendee && attendee.is_member
    }
  end

  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end



end
