defmodule ApiWeb.Api.V1_0.UserChatView do
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserChatView

  alias Data.Context
  alias Data.Context.{RoomMessageMetas, RoomUsers}

  def render("room_chat_messages.json", %{
        room_id: room_id,
        messages: messages,
        room_users: room_users
      }) do
    %{
      room_id: room_id,
      room_users: render_many(room_users, UserChatView, "room_user.json", as: :room_user),
      chat_messages: %{
        data: render_many(messages.entries, UserChatView, "user_message.json", as: :message),
        pagination: %{
          total_rows: messages.total_entries,
          page: messages.page_number,
          total_pages: messages.total_pages
        }
      }
    }
  end

  def render("users.json", %{users: users}) do
    data = ApiWeb.Api.V1_0.UserView.render("users_for_chat.json", %{users: users.entries})
    page_data = %{
      total_rows: users.total_entries,
      page: users.page_number,
      total_pages: users.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("room_messages.json", %{room_messages: room_messages}) do
    room_messages_data = render_many(room_messages, UserChatView, "user_message.json", as: :message)
    page_data = %{
      total_rows: room_messages.total_entries,
      page: room_messages.page_number,
      total_pages: room_messages.total_pages
    }
    %{data: room_messages_data, pagination: page_data}
  end

  def render("user_message.json", %{message: message}) do
    replies = case message.replies do
      %Ecto.Association.NotLoaded{} ->
        []
      _ ->
        render_many(message.replies, UserChatView, "replies.json", as: :reply)
    end
    user_messages(message)
    |> Map.merge(%{replies: replies})
  end

  def render("replies.json", %{reply: reply}) do
    user_messages(reply)
  end

  def render("user_message.json", %{error: error}) do
    %{errors: error}
  end

  def render("message_image.json", %{message_image: message_image}) do
    message_image.image
  end

  def render("room_members.json", %{room_users: room_users}) do
    render_many(room_users, UserChatView, "room_user.json", as: :room_user)
  end

  def render("room_user.json", %{room_user: room_user}) do

    user = room_user.user
    %{
      is_active: user.is_active,
      user_id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      user_image: user.image_name,
      image_thumbnail: user.small_image_name,
      role: room_user.user_role
    }
  end

  def render("user_rooms.json", %{user_rooms: user_rooms} = data) do
#    users_room_data = render_many(user_rooms, UserChatView, "user_room.json", as: :user_room)
    users_room_data = Enum.map(user_rooms, fn room ->
      render("user_room.json", %{user_room: room, current_user_id: data[:current_user_id]})
    end)
  total_unread_chats = data[:current_user_id] && RoomMessageMetas.get_count_of_unread_chats(data[:current_user_id])  || 0
    page_data = %{
      total_rows: user_rooms.total_entries,
      page: user_rooms.page_number,
      total_pages: user_rooms.total_pages
    }
    %{total_unread_chats: total_unread_chats, data: users_room_data, pagination: page_data}
  end

  def render("user_room.json", %{user_room: user_room} = data) do
    #TODO - prevent showing blocked or deleted user data
    current_user_id = data[:current_user_id]
    room_users = RoomUsers.get_room_users(user_room.id)
    room_last_message =
      Context.RoomMessages.get_room_last_message(user_room.id, current_user_id)
    payload = %{
      room_id: user_room.id,
      room_type: user_room.room_type,
      group_name: user_room.group_name,
      image_name: user_room.image_name,
      image_thumbnail: user_room.small_image_name,
      unread_message_count: current_user_id && RoomMessageMetas.get_count_of_unread_message(current_user_id, user_room.id) || 0,
      room_users: render_many(room_users.entries, UserChatView, "room_user.json", as: :room_user),
      last_message:
        render_one(room_last_message, UserChatView, "user_message.json", as: :message),
      user_event:
        render_one(
          user_room.user_event |> Context.UserEvents.preload_all(),
          ApiWeb.Api.V1_0.UserEventView,
          "user_event.json",
          as: :user_event
        ),
      image_name: user_room.image_name
    }
    if data[:event] == "update" do
      data = Casex.to_camel_case(payload)
      data = Map.put(data, "baseUrl", "https://#{System.get_env("IMAGE_BASE_URL")}/")
      Task.start(fn ->
        Enum.each(room_users, fn room_user ->
          ApiWeb.Endpoint.broadcast("user:" <> room_user.user_id, "group_chat_updated", data)
        end)
      end)
      payload
      else
    payload
    end
  end

  def render("room-detail.json", %{room: room}) do
    #TODO - prevent showing blocked or deleted user data
    room_users = RoomUsers.get_room_users(room.id)
    referral_code = Data.Context.RoomReferralCodes.get_referral_code_by_room_id(room.id)
    %{
      room_id: room.id,
      room_type: room.room_type,
      group_name: room.group_name,
      image: room.image_name,
      image_thumbnail: room.small_image_name,
      total_users: RoomUsers.count_room_users(room.id),
      room_users: render_many(room_users.entries, UserChatView, "room_user.json", as: :room_user),
      referral_code: referral_code
    }
  end

  def render("room_users.json", %{room_users: %{entries: entries} = room_users})do

    data = Enum.map(entries , fn room_user ->
      render("room_user.json", %{room_user: room_user})
    end)
    page_data = %{
      total_rows: room_users.total_entries,
      page: room_users.page_number,
      total_pages: room_users.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("user_groups.json", %{followers: followers, following: following, suggested: suggested}) do
    %{
      followers: %{
      pagiation: %{
        total_rows: followers.total_entries,
        page: followers.page_number,
        total_pages: followers.total_pages
        },
        data: ApiWeb.Api.V1_0.UserView.render("users_for_chat.json", %{users: followers.entries})
      },
      following: %{
        pagiation: %{
          total_rows: following.total_entries,
          page: following.page_number,
          total_pages: following.total_pages
        },
        data: ApiWeb.Api.V1_0.UserView.render("users_for_chat.json", %{users: following})
      },
      suggested: %{
        pagiation: %{
          total_rows: suggested.total_entries,
          page: suggested.page_number,
          total_pages: suggested.total_pages
        },
        data: Enum.map(suggested.entries, fn interest ->
        %{
          interest_name: interest.interest_name,
          interest_id: interest.id,
          users: ApiWeb.Api.V1_0.UserView.render("users_for_chat.json", %{users: interest.user_interests})
        }
        end)
      }
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def render("referral_code.json", %{message: message}), do: message

  defp user_messages(message) do
    %{
      message_id: message.id,
      message: message.message,
      message_time: message.inserted_at,
      no_of_likes: message.room_message_meta && message.room_message_meta.no_of_likes,
      message_images:
        render_many(message.message_images, UserChatView, "message_image.json", as: :message_image),
      callback_verification: message.callback_verification,
      user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: message.sender}),
      is_read: RoomMessageMetas.check_message_read_by_message_id?(message.id)
    }
  end

end
