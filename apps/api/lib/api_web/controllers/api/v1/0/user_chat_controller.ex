#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserChatController do
  @moduledoc """
  Manage chat rooms.
  """

  @referral_code_url Application.get_env(:api, :configuration)[:referral_code_url]

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Repo
  alias JetzyModule.AssetStoreModule, as: AssetStore

  alias Data.Context.{
    Rooms,
    RoomMessages,
    RoomUsers,
    Users,
    UserBlocks,
    RoomReferralCodes,
    RoomMessageMetas,
    NotificationsRecords
    }

  alias Data.Schema.{
    RoomReferralCode,
    Room,
    RoomUser,
    User,
    InterestTopic,
    UserEvent,
    NotificationType,
    PushNotificationMessage,
    RoomMessage
  }

  #  import Ecto.Multi
  alias ApiWeb.Utils.PushNotification
  alias ApiWeb.Utils.Common

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # start_user_chat\2
  #----------------------------------------------------------------------------
  swagger_path :start_user_chat do
    post("/v1.0/start-user-chat")
    summary("Start User Chat / get a user_chat room by room_id")

    description(
      "Start User Chat (send User ID to start chat with him/her), If you give group_name with referral_code without any user_id then it will create a private group and only are the member of this group.
        also if you send room_id directly it will respond you with room if exists"
    )

    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:StartUserChat), "returns that started chat", required: true)
    end

    response(200, "Ok", Schema.ref(:ChatRoomInListing))
  end

  @doc """
  Start user chat.
  Start User Chat (send User ID to start chat with him/her), If you give group_name with referral_code without any user_id then it will create a private group and only are the member of this group.
  """
  def start_user_chat(conn, %{"user_id" => user_id} = params) do
    %{id: current_user_id, first_name: _first_name} = user = Api.Guardian.Plug.current_resource(conn)

    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b33"
    with false <- UserBlocks.get_blocked_status(current_user_id, user_id),
         %{enabled: true} <- Data.Schema.User.quick_chat_settings(user_id, user),
         %{is_deleted: false, is_deactivated: false, is_self_deactivated: false} <- Context.get(User, user_id),
         nil <- Rooms.get_user_chat_room(current_user_id, user_id) do
      {:ok, room} = Context.create(Room, %{room_type: "user_chat"})
      #make shareable link
      make_shareable_link(room)
      if params["referral_code"],
         do:
           Context.create(RoomReferralCode, %{
             room_id: room.id,
             user_id: user_id,
             referral_code: params["referral_code"]
           })

      {:ok, _} = Context.create(RoomUser, %{room_id: room.id, user_id: current_user_id})
      {:ok, _} = Context.create(RoomUser, %{room_id: room.id, user_id: user_id})
      ApiWeb.Utils.Common.update_points(current_user_id, :started_new_conversation_with_user)
      ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)

      #          push_notification_params = %{"keys" => %{"first_name" => first_name},
      #            "event" => "user_message_chat", "user_id" => user.id, "sender_id" => current_user_id,
      #            "template_name" => "notification_email.html", "type" => "user_message_chat", "resource_id" => user.id}
      #          ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
      #          ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: user.email}, push_notification_params)
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
    else
      %{enabled: false, message: m} -> render(conn, "error.json", %{error: m || "Action Restricted"})
      true -> render(conn, "error.json", %{error: "Could not start chat"})

      nil -> render(conn, "error.json", %{error: "The user does not exist"})

      %{is_deleted: _del, is_deactivated: _deac, is_self_deactivated: _sdeac} ->
        render(conn, "error.json", %{error: "The user is either deactivated or deleted"})

      %Room{} = room ->
        ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)
        render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: user_id})

      _ -> render(conn, "error.json", %{error: "Something went wrong"})
    end
  end

  def start_user_chat(conn, %{"room_id" => room_id}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Room{room_type: "user_chat"} = room <- Context.get(Room, room_id),
         true <- RoomUsers.user_exists_in_room(room_id, current_user_id) do
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
      else
      false -> render(conn, "error.json", %{error: "User does not exist in the room"})
      %Room{} -> render(conn, "error.json", %{error: "Not a valid user chat room"})
      nil -> render(conn, "error.json", %{error: "Room does not exist"})
    end
  end

  def start_user_chat(
        conn,
        %{"referral_code" => _referral_code, "group_name" => group_name} = params
      ) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b33"
    with {:ok, room} <-
           Context.create(Room, %{
             room_type: "user_chat",
             is_private: true,
             group_name: group_name
           }),

         {:ok, _referral_code} <-
           Context.create(RoomReferralCode, %{
             room_id: room.id,
             user_id: current_user_id,
             referral_code: params["referral_code"]
           }),
         {:ok, _} <- Context.create(RoomUser, %{room_id: room.id, user_id: current_user_id}),
         _ <-
           ApiWeb.Utils.Common.update_points(
             current_user_id,
             38
           ) do
      #make shareable link
      make_shareable_link(room)
      ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(current_user_id, room)
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
    else
      {:error, error} ->
        render(conn, "user_message.json", %{error: error})

      %{} = room ->
        ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(current_user_id, room)
        render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/room-user")
    summary("Add User or users to Chat")
    description("Add user or users to a chat room by their User ID/Id's")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:AddRoomUser), "Add a user to a chat room", required: true)
    end

    response(200, "Ok", Schema.ref(:AddUserToChat))
  end

  @doc """
  Add user to chatroom.
  """
  def create(conn, %{"user_id" => user_id, "room_id" => room_id}) when not is_list(user_id) and is_binary(user_id) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with true <- RoomUsers.user_exists_in_room(room_id, current_user_id),
         %{is_deleted: false, is_deactivated: false, is_self_deactivated: false} = user <-
           Context.get(User, user_id),
         false <- UserBlocks.get_blocked_status(current_user_id, user_id),
         nil <- Context.get_by(RoomUser, room_id: room_id, user_id: user_id) do
      {:ok, room_user} = case Context.get(Room, room_id) do
        %Room{room_type: "group_chat"} ->
          Context.create(RoomUser, %{room_id: room_id, user_id: user_id, user_role: "member"})
        _ ->
          Context.create(RoomUser, %{room_id: room_id, user_id: user_id})
      end
      room_user =
        Map.from_struct(room_user)
        |> Map.put(:user, Map.from_struct(user))

      render(conn, "room_user.json", room_user: room_user)
    else
      false -> render(conn, "error.json", error: "You are not permitted!")
      nil -> render(conn, "error.json", error: "User does not exist")
      true -> render(conn, "error.json", error: "Could not add user.")
      %{is_deleted: _del, is_deactivated: _deac, is_self_deactivated: _sdeac} ->
        render(conn, "error.json", error: "User deleted or deactivated")
      %RoomUser{} -> render(conn, "error.json", error: "User already in room")
      {:error, error} -> render(conn, "error.json", error: error)
      _ -> render(conn, "error.json", error: "Something went wrong")
    end
  end

  def create(conn, %{"user_id" => user_ids, "room_id" => room_id}) when is_list(user_ids) do
    %{id: current_user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    if RoomUsers.user_exists_in_room(room_id, current_user_id) do
      room_users = Enum.reduce(user_ids, [], fn user_id, acc ->
        add_user_in_room(current_user_id, user_id, room_id, acc, first_name, last_name)
      end)
      render(conn, "room_members.json", room_users: room_users)
    else
      render(conn, "error.json", error: "You are not permitted!")
    end
  end

  def add_user_in_room(current_user_id, user_id, room_id, acc, first_name, last_name) do
    with %{is_deleted: false, is_deactivated: false, is_self_deactivated: false} = user <-
      Context.get(User, user_id),
    false <- UserBlocks.get_blocked_status(current_user_id, user_id),
    nil <- Context.get_by(RoomUser, room_id: room_id, user_id: user_id) do
     {:ok, room_user} = case Context.get(Room, room_id) do
         %Room{room_type: "group_chat"} ->
           room_user = Context.create(RoomUser, %{room_id: room_id, user_id: user_id, user_role: "member"})
             %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
             "event" => "add_member_to_chat_group", "user_id" => user_id, "sender_id" => current_user_id, "type" => "add_member_to_chat_group", "resource_id" => room_id}
             |> ApiWeb.Utils.PushNotification.send_push_notification()
           room_user
           _ ->
            Context.create(RoomUser, %{room_id: room_id, user_id: user_id})
     end
    room_user =
      Map.from_struct(room_user)
      |> Map.put(:user, Map.from_struct(user))
      [room_user | acc]
    else
      _ -> acc
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/room-user")
    summary("Delete a User from Chat")
    description("Delete a user from a room by ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:DeleteRoomUser), "Add a user to a chat room", required: true)
    end

    response(200, "Ok", Schema.ref(:DeleteUserFromChat))
  end

  @doc """
  Remove user from Chat.
  @todo we might be not delete all the previous messages. But now we are deleting all the messages - tanbits
  """
  def delete(conn, %{"user_id" => user_id, "room_id" => room_id}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    case Context.get(Room, room_id) do
      %Room{room_type: "group_chat"} ->
        requested_by = Context.get_by(RoomUser, room_id: room_id, user_id: current_user_id)
        cond do
          is_nil(requested_by) ->
            render(conn, "error.json", error: "Record does not exist")
          requested_by.user_role == "admin" ->
            case delete_room_user(room_id, user_id) do
              %{} = room_user ->
                Task.async(RoomMessageMetas, :soft_delete_all_messages, [user_id, room_id])
                Task.async(NotificationsRecords, :delete_notification_by_receiver_and_resource_id, [user_id, room_id])
                if !RoomUsers.room_user_exists?(room_id) do
                  render(conn, "room_user.json", room_user: room_user, current_user_id: current_user_id)
                else
                  if !RoomUsers.check_admin_exists?(room_id, current_user_id) do
                    old_room_user = RoomUsers.get_oldest_room_user(room_id)
                    Context.update(RoomUser, old_room_user, %{user_role: "admin"})
                  end
                  render(conn, "room_user.json", room_user: room_user, current_user_id: current_user_id)
                end

              :error -> render(conn, "error.json", error: "Record does not exist")
            end

          requested_by.user_role == "member" && current_user_id == user_id ->
            case delete_room_user(room_id, user_id) do
              %{} = _room_user ->
                room_user = delete_room_user(room_id, user_id)
                Task.async(RoomMessageMetas, :soft_delete_all_messages, [user_id, room_id])
                Task.async(NotificationsRecords, :delete_notification_by_receiver_and_resource_id, [user_id, room_id])
                render(conn, "room_user.json", room_user: room_user, current_user_id: current_user_id)
              :error ->
                render(conn, "error.json", error: "Record does not exist")
            end
          true ->
            render(conn, "error.json", error: "You are not permitted!")
        end
      _ ->
        with true <- is_creator_for_room(room_id, current_user_id),
             %User{} = user <- Context.get(User, user_id),
             %RoomUser{} = room_user <- Context.get_by(RoomUser, room_id: room_id, user_id: user_id),
             {:ok, data} <- Context.delete(room_user) do
          Task.async(RoomMessageMetas, :soft_delete_all_messages, [user_id, room_id])
          Task.async(NotificationsRecords, :delete_notification_by_receiver_and_resource_id, [user_id, room_id])
          user = Map.from_struct(user)
          room_user = Map.from_struct(data) |> Map.put(:user, user)
          render(conn, "room_user.json", room_user: room_user, current_user_id: current_user_id)
        else
          false -> render(conn, "error.json", error: "You are not permitted!")
          nil -> render(conn, "error.json", error: "Record does not exist")
          {:error, error} -> render(conn, "error.json", error: error)
          _ -> render(conn, "error.json", error: "Something went wrong")
        end
    end
  end

  #----------------------------------------------------------------------------
  # delete_message/2
  #----------------------------------------------------------------------------
  swagger_path :delete_message do
    PhoenixSwagger.Path.delete("/v1.0/room-message")
    summary("Delete a Message from Chat")
    description("Delete a Message from a room by ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:DeleteRoomMessage), "List of Message ids", required: true)
    end

    response(200, "Ok", Schema.ref(:DeleteRoomMessage))
  end

  @doc """
  Clear chat messages by room id.
  """
  def delete_message(conn, %{"room_message_ids" => room_message_ids}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    case RoomMessageMetas.soft_delete_message(current_user_id, room_message_ids) do
      {0, nil} -> render(conn, "message.json", message: "No message deleted")
      {n, nil} ->
        message_id = List.first(room_message_ids)
        %RoomMessage{room_id: room_id} = Context.get(RoomMessage, message_id)
        broadcast_delete_for_me(current_user_id, %{room_id: room_id})
        render(conn, "message.json", message: "#{n} message deleted")
    end
  end


  #----------------------------------------------------------------------------
  # user_room_chat/2
  #----------------------------------------------------------------------------
  swagger_path :user_room_chat do
    get("/v1.0/user-room-chat")
    summary("Get Messages or comments by room ID")
    description("Get data by room ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      room_id(:query, :string, "Room ID", required: true)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:ChatMessage))
  end

  @doc """
  Get chat room messages.
  """
  #TODO here we might be show messages of the room if user previously exist in the room. but for now we are not showing messages after user leave room
  def user_room_chat(conn, %{"room_id" => room_id, "page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Room{} <- Context.get(Room, room_id),
    true <- RoomUsers.user_exists_in_room(room_id, user_id) do
      room_messages = RoomMessages.get_messages_by_room(room_id, page, user_id)
      render(conn, "room_messages.json", room_messages: room_messages)
      else
      nil -> render(conn, "error.json", %{error: "Room does not exist"})
      false -> render(conn, "error.json", %{error: "User does not exist in the room"})
      _ -> render(conn, "error.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # user_chats/2
  #----------------------------------------------------------------------------
  swagger_path :user_chats do
    get("/v1.0/user-chats")
    summary("User Chats")
    description("Get list (rooms) of all user chats")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page no.", required: true)
      search_string(:query, :string, "Search String")
    end

    response(200, "Ok", Schema.ref(:UserChatRoomsList))
  end

  @doc """
  Get list of chat rooms user is currently a member of.
  """
  def user_chats(conn, %{"page" => page} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    user_rooms = case params["search_string"] do
      nil ->
        Rooms.get_all_user_chat_rooms(user_id, page)

      search_string ->
        Rooms.search_chat(user_id, search_string, page)
    end
    room_entries = Rooms.preload_selective(user_rooms.entries)
    render(conn, "user_rooms.json",
      user_rooms: Map.merge(user_rooms, %{entries: room_entries}),
      current_user_id: user_id
    )
  end

  #----------------------------------------------------------------------------
  # users_for_chat/2
  #----------------------------------------------------------------------------
  swagger_path :users_for_chat do
    get("/v1.0/users-for-chat")
    summary("Show Users")
    description("List of Users to chat with")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      room_id(:query, :string, "Room ID.")
      page(:query, :integer, "Page no.", required: true)
      search(:query, :string, "Search")
    end

    response(200, "Ok", Schema.ref(:UserGroups))
  end
  @doc """
  List users to add in a group chat.
  """
  def users_for_chat(conn, %{"page" => page, "search" => search} = params) do
    %{id: current_user_id, latitude: lat, longitude: long} = user = Api.Guardian.Plug.current_resource(conn)
    if Map.has_key?(params, "room_id") do
      users = Users.paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: lat, long: long, page: page, search: search, room_id: params["room_id"]})
              |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
      render(conn, "users.json", %{users: users})
    else
#      followers = Users.paginate_user_followers(%{page: page, search: search}, current_user_id)
#      following = Users.paginate_user_following(%{page: page, search: search}, current_user_id)
#      suggested = Users.paginate_users_with_similar_interests(%{page: page, search: search}, current_user_id)
      users = Users.paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: lat, long: long, page: page, search: search})
              |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
#      render(conn, "user_groups.json", %{followers: followers, following: following, suggested: suggested})
      render(conn, "users.json", %{users: users})
    end
  end

  def users_for_chat(conn, %{"page" => page} = params) do
    %{id: current_user_id, latitude: lat, longitude: long} = user = Api.Guardian.Plug.current_resource(conn)
    if Map.has_key?(params, "room_id") do
      users = Users.paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: lat, long: long, page: page, room_id: params["room_id"]})
              |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
      render(conn, "users.json", %{users: users})
    else
#      followers = Users.paginate_user_followers(%{page: page}, current_user_id)
#      following = Users.paginate_user_following(%{page: page}, current_user_id)
#      suggested = Users.paginate_users_with_similar_interests(%{page: page}, current_user_id)
       users = Users.paginate_users_for_group_chat(%{current_user_id: current_user_id, lat: lat, long: long, page: page})
               |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
#      render(conn, "user_groups.json", %{followers: followers, following: following, suggested: suggested})
#      render(conn, "users.json", %{users: %{entries: [], total_entries: 0, page_number: 1, total_pages: 0}})
      render(conn, "users.json", %{users: users})
    end
  end


  #----------------------------------------------------------------------------
  # selective_users_for_chat/2
  #----------------------------------------------------------------------------

  swagger_path :selective_users_for_chat do
    get("/v1.0/selective-users-for-chat")
    summary("Show Users")
    description("List Users to add in a group chat")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      catagory(:query, :string, "Group of user followers/following/interest_id")
      page(:query, :integer, "Page no.", required: true)
      search(:query, :string, "Search")
    end

    response(200, "Ok", Schema.ref(:Users))
  end
  @doc """
  List users to add in a group chat.
  """
  def selective_users_for_chat(conn, %{"page" => page, "catagory" => catagory} = params) do
    %{id: current_user_id, latitude: lat, longitude: long} = user = Api.Guardian.Plug.current_resource(conn)
    params = Map.has_key?(params, "search") && %{page: page, search: params["search"]} || %{page: page}
    case catagory do
      "followers" ->
        followers = Users.paginate_user_followers(params, current_user_id)
                    |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
        render(conn, "users.json", %{users: followers})

      "following" ->
        following = Users.paginate_user_following(params, current_user_id)
                    |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
        render(conn, "users.json", %{users: following})

      interest_id ->
        interest_users = Users.paginate_users_by_interest_id(%{page: page, interest_id: interest_id}, current_user_id)
                         |> update_in([Access.key(:entries)], &(&1 && Enum.map(&1, fn(u) -> Data.Schema.User.set_chat_settings(u, user) end)))
        render(conn, "users.json", %{users: interest_users})
    end
  end


  #----------------------------------------------------------------------------
  # send_invite_of_room/2
  #----------------------------------------------------------------------------
  swagger_path :send_invite_of_room do
    post("/v1.0/send-invite")
    summary("Send Referral code of room")
    description("Send Referral code of room")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:SendInvite), "send referral code of room", required: true)
    end
  end

  @doc """
  Send chat room invitation to user.
  """
  def send_invite_of_room(conn, %{"email" => email, "referral_code" => referral_code}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)

    with %{id: user_id, is_deleted: false, is_deactivated: false, is_self_deactivated: false} = invited_user <- Users.get_user_by_email(email),
         false <- UserBlocks.get_blocked_status(current_user_id, user_id),
         %{} = room_referral_code <- RoomReferralCodes.is_exist_referral_code(referral_code),
         private_group_name <- Rooms.get_group_name_by_room_id(room_referral_code.room_id) do
      user = %{email: email, first_name: invited_user.first_name}

      push_notification_params = %{
        "keys" => %{"first_name" => invited_user.first_name, "last_name" => invited_user.last_name, "private_group_name" => private_group_name},
        "event" => "private_group_invite_received",
        "user_id" => invited_user.id,
        "sender_id" => current_user_id,
        "type" => "private_group_invite_received",
        "resource_id" => invited_user.id
      }

      notification = get_message_for_send_email(push_notification_params)

      email_params = %{
        "url" => "#{@referral_code_url}#{referral_code}",
        "first_name" => user.first_name,
        "referral_code" => referral_code,
        "notification" => notification
      }

      with {:ok, _pid} <- Api.Mailer.send_room_referral_code(user, email_params),
           ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params) do
        render(conn, "referral_code.json", %{message: "Email Sent"})
      else
        {:error, _} -> render(conn, "referral_code.json", %{message: "Error in sending email"})
      end
    else
      true -> render(conn, "referral_code.json", %{message: "Could not send Invite."})
      %{is_deleted: _del, is_deactivated: _deac, is_self_deactivated: _sdeac} ->
        render(conn, "referral_code.json", %{message: "User deleted or deactivated"})
      nil -> render(conn, "referral_code.json", %{message: "Something Went Wrong"})
    end
  end


  #----------------------------------------------------------------------------
  # add_user_in_room_with_referrer_code/2
  #----------------------------------------------------------------------------
  swagger_path :add_user_in_room_with_referrer_code do
    post("/v1.0/add-invited-user-in-room")
    summary("Add Invited User in Room")
    description("Add Invited User in Room")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:AddInvitedUser), "Add invited user in room", required: true)
    end
  end

  @doc """
  Add user to chat room via referrer code.
  """
  def add_user_in_room_with_referrer_code(conn, %{
    "referral_code" => referral_code,
    "user_id" => user_id,
    "response" => response
  }) do
    %{id: current_user_id, first_name: _first_name} = Api.Guardian.Plug.current_resource(conn)
    if response == true do
      with %{is_deleted: false, is_deactivated: false, is_self_deactivated: false} = user <- Context.get(User, user_id),
           false <- UserBlocks.get_blocked_status(current_user_id, user_id),
           %{room_id: room_id} <- RoomUsers.get_room_id_by_referral_code(referral_code),
           room <- Context.get(Room, room_id),
           {:ok, room_user} <- Context.create(RoomUser, %{room_id: room_id, user_id: user_id}) do
        push_notification_params_for_current_user = %{
          "keys" => %{
            "first_name" => user.first_name,
            "last_name" => user.last_name,
            "response" =>  "accepted",
            "private_group_name" => room.group_name
          },
          "event" => "private_group_invitation_response",
          "user_id" => room_user.user_id,
          "sender_id" => current_user_id,
          "type" => "private_group_invitation_response",
          "resource_id" => room_id
        }

        push_notification_params_for_invited_user = %{
          "keys" => %{first_name: user.first_name, private_group_name: room.group_name},
          "event" => "private_group_request_accepted",
          "user_id" => user_id,
          "type" => "private_group_request_accepted",
          "resource_id" => user_id
        }

        Enum.map(
          [push_notification_params_for_current_user, push_notification_params_for_invited_user],
          fn x ->
            ApiWeb.Utils.PushNotification.send_push_notification(x)
          end
        )

        render(conn, "referral_code.json", %{
          message: "Welcome to Jetzy, you are now part of the #{room.group_name} community"
        })
      else
        nil ->
          render(conn, "referral_code.json", %{
            message: "No room ID found against this referral code"
          })

        {:error, _} ->
          render(conn, "referral_code.json", %{
            message: "Error in creating user against the room id of this referral code"
          })
        true -> render(conn, "referral_code.json", %{message: "Could not send Request."})
        %{is_deleted: _del, is_deactivated: _deac, is_self_deactivated: _sdeac} -> render(conn, "referral_code.json", %{message: "User deleted or deactivated"})
      end
    else
      render(conn, "referral_code.json", %{message: "Request Rejected"})
    end
  end

  #----------------------------------------------------------------------------
  # delete_user_chat/2
  #----------------------------------------------------------------------------
  swagger_path :delete_user_chat do
    PhoenixSwagger.Path.delete("/v1.0/delete-user-chat")
    summary("Delete a chat")
    description("Delete a chat")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      room_id(:query, :string, "Room ID", required: true)
    end

    response(200, "Ok", %{status: "Chat Deleted"})
  end

  @doc """
  Delete a user chat room.
  """
  def delete_user_chat(conn, %{"room_id" => room_id} = _params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    room_id = String.trim(room_id)
    case UUID.info(room_id) do
      {:error, _} -> json(conn, %{ResponseData: %{error: "Not a valid id"}})
      _ ->
        if Rooms.check_room_exists?(room_id) do
          Task.async(RoomMessageMetas, :soft_delete_all_messages, [current_user_id, room_id])
          room = Data.Context.get(Room, room_id)
          Data.Context.update(Room, room, %{deleted_by: current_user_id})
          json(conn, %{ResponseData: %{status: "Chat Deleted"}})
        else
          json(conn, %{ResponseData: %{error: "No room exists"}})
        end

    end
  end

#----------------------------------------------------------------------------
# start_group_chat/2
#----------------------------------------------------------------------------
swagger_path :start_group_chat do
  post("/v1.0/start-group-chat")
  summary("Start a group chat / or get a group by room_id")
  description("Start a group chat / or get a group by room_id")
  produces("application/json")
  security([%{Bearer: []}])
    parameters do
      body(:body, Schema.ref(:StartGroupChat), "returns that started chat", required: true)
    end

    response(200, "Ok", Schema.ref(:ChatRoomInListing))
  end

  @doc """
  Start a group chat.
  """
  def start_group_chat(conn,  %{"group_name" => group_name, "user_ids" => user_ids} = params) do
    %{id: current_user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34"
    {room_image, small_image} = case AssetStore.upload_if_image_with_thumbnail(params, "image", "room") do
      nil -> {nil, nil}
      [] -> {nil, nil}
      image -> image
    end
    #    with %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} <- Context.get(User, user_id),
    #         false <- is_deleted or is_deactivated or is_self_deactivated do
    filtered_user_ids = filter_users(user_ids, current_user_id)
    if filtered_user_ids != [] do
      {:ok, room} = Context.create(Room, %{room_type: "group_chat", group_name: group_name, created_by: current_user_id, image_name: room_image, small_image_name: small_image})
      #make shareable link
      make_shareable_link(room)

      #TODO refferal code in group chat pending
      if params["referral_code"],
         do:
           Context.create(RoomReferralCode, %{
             room_id: room.id,
             user_id: current_user_id,
             referral_code: params["referral_code"]
           })

      {:ok, _} = Context.create(RoomUser, %{room_id: room.id, user_id: current_user_id, user_role: "admin"})

      Enum.each(filtered_user_ids, fn user_id ->
        Context.create(RoomUser, %{room_id: room.id, user_id: user_id, user_role: "member"})
        push_notification_params = [
          %{
            "keys" => %{
              "first_name" => first_name,
              "last_name" => last_name
            },
            "event" => "add_member_to_chat_group",
            "user_id" => user_id,
            "sender_id" => current_user_id,
            "type" => "add_member_to_chat_group",
            "resource_id" => room.id
          },
          %{
            "keys" => %{
              "first_name" => first_name,
              "last_name" => last_name,
              "group_name" => group_name
            },
            "event" => "chat_group_created",
            "user_id" => user_id,
            "sender_id" => current_user_id,
            "type" => "chat_group_created",
            "resource_id" => room.id
          }
        ]
       Enum.each(push_notification_params, fn push_notification_param ->
         ApiWeb.Utils.PushNotification.send_push_notification(push_notification_param) end)

      end)
      ApiWeb.Utils.Common.update_points(current_user_id, :started_new_group_conversation)
      Enum.each(filtered_user_ids, fn user_id ->
        ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)
      end)


      #          push_notification_params = %{"keys" => %{"first_name" => first_name},
      #            "event" => "user_message_chat", "user_id" => user.id, "sender_id" => current_user_id,
      #            "template_name" => "notification_email.html", "type" => "user_message_chat", "resource_id" => user.id}
      #          ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
      #          ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: user.email}, push_notification_params)
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
    else
      render(conn, "error.json", %{error: "Something went wrong"})
    end
    #    else
    #      nil ->
    #        render(conn, "error.json", %{error: "The user does not exist"})
    #
    #      true ->
    #        render(conn, "error.json", %{error: "The user is either deactivated or deleted"})
    #
    #      _ ->
    #        render(conn, "error.json", %{error: "Something went wrong"})
    #    end
  end

  def start_group_chat(conn,  %{"room_id" => room_id} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Room{} = room <- Context.get(Room, room_id),
          true <- room.room_type in ["group_chat", "event_chat", "interest_topic_chat"],
         true <- RoomUsers.user_exists_in_room(room_id, current_user_id) do
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id})
    else
      false -> render(conn, "error.json", %{error: "User does not exist in the room"})
      %Room{} -> render(conn, "error.json", %{error: "Not a valid group chat room"})
      nil -> render(conn, "error.json", %{error: "Room does not exist"})
    end
  end
  #----------------------------------------------------------------------------
  # show_group_detail/2
  #----------------------------------------------------------------------------
  swagger_path :show_room_detail do
    get("/v1.0/chat-group-detail/{room_id}")
    summary("Shows Chat Group Details")
    description("Shows Chat Group Details")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      room_id(:path, :string ,"Room id of the required room", required: true)
    end

    response(200, "Ok", Schema.ref(:GroupDetail))
  end

  @doc """
  Show Room detail
  """

  def show_room_detail(conn, %{"room_id" => room_id} = _params) do
    case Context.get(Room, room_id) do
      nil -> render(conn, "user_message.json", %{error: "Room does not exist against this id"})
      %Room{} = room -> render(conn, "room-detail.json", %{room: room})
    end
  end

  #----------------------------------------------------------------------------
  # room_users/2
  #----------------------------------------------------------------------------
  swagger_path :show_room_users do
    get("/v1.0/room-users")
    summary("Show Chat Group Users")
    description("Show Chat Group Users")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      room_id(:query, :string ,"Room id of the required room", required: true)
      page(:query, :integer, "Page no.", required: true)
      search(:query, :string, "Search")
    end

    response(200, "Ok", Schema.ref(:GroupDetail))
  end

  @doc """
  Show Room Users
  """

  def show_room_users(conn, %{"room_id" => room_id, "page" => page} = params) do
   room_users = RoomUsers.room_users(room_id, page, params["search"])
   render(conn, "room_users.json", %{ room_users: room_users})
  end

  #----------------------------------------------------------------------------
  # update_group_chat/2
  #----------------------------------------------------------------------------
  swagger_path :update_group_chat do
    put("/v1.0/update-group-chat/{id}")
    summary("Update a group chat")
    description("Update a group chat")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      id(:path, :string, "Room ID", required: true)
      body(:body, Schema.ref(:UpdateGroupChat), "returns that started chat", required: true)
    end

    response(200, "Ok", Schema.ref(:ChatRoomInListing))
  end

  @doc """
  Update a group chat.
  """
  def update_group_chat(conn, %{"id" => id} = params) do
    %{id: current_user_id, first_name: _first_name} = Api.Guardian.Plug.current_resource(conn)
    params = case AssetStore.upload_if_image_with_thumbnail(params, "image", "room") do
      nil -> params
      {room_image, small_image} -> Map.merge(params, %{"image_name" => room_image, "small_image_name" => small_image})
    end
    with %Room{} = room <- Context.get(Room, id),
         {:ok, %Room{} = room} <- Context.update(Room, room, params) do
      if params["referral_code"] do
           Context.create(RoomReferralCode, %{
             room_id: room.id,
             user_id: current_user_id,
             referral_code: params["referral_code"]
           })
      end
      render(conn, "user_room.json", %{user_room: Rooms.preload_selective(room), current_user_id: current_user_id, event: "update"})
      else
      nil ->
        render(conn, "error.json", %{error: "The room does not exist"})
    end
  end

  #----------------------------------------------------------------------------
  # make_group_admin/2
  #----------------------------------------------------------------------------

  swagger_path :make_group_admin do
    post("/v1.0/make-group-admin")
    summary("Make a user admin of a specific room")
    description("Make a user admin of a specific room")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      body(:body, Schema.ref(:DeleteRoomUser) ,"Room id and User Id", required: true)
    end

    response(200, "Ok", Schema.ref(:MakeAdmin))
  end

  @doc """
  Show Room detail
  """

  def make_group_admin(conn, %{"room_id" => room_id, "user_id" => user_id} = _params) do
    %{id: current_user_id, first_name: _first_name} = Api.Guardian.Plug.current_resource(conn)
    with {:ok, _} <- Ecto.UUID.dump(room_id),
     {:ok, _} <- Ecto.UUID.dump(user_id),
        %Room{room_type: "group_chat"} <- Context.get(Room, room_id),
         %RoomUser{user_role: "member"} = room_user <- Context.get_by(RoomUser, [room_id: room_id, user_id: user_id]),
         true <- RoomUsers.is_group_admin?(current_user_id, room_id)
      do
      Context.update(RoomUser, room_user, %{user_role: "admin"})
      render(conn, "message.json", %{message: "User is now admin"})
    else
      %Room{} = room -> render(conn, "message.json", %{message: "Invalid room id"})
      %RoomUser{user_role: "admin"} -> render(conn, "message.json", %{message: "User is already admin"})
      nil -> render(conn, "error.json", %{error: "Wrong room or user id"})
      false -> render(conn, "error.json", %{error: "Permission denied"})
      :error -> render(conn, "error.json", %{error: "Enter a valid UUID"})
    end

  end

  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # delete_room_user/2
  #----------------------------------------------------------------------------
  defp delete_room_user(room_id, user_id) do
    case Context.get_by(RoomUser, room_id: room_id, user_id: user_id) do
     %RoomUser{} = room_user ->
       {:ok, data} = Context.delete(room_user)
       user = Context.get(User, user_id)
       user = Map.from_struct(user)
       Map.from_struct(data) |> Map.put(:user, user)
       nil -> :error
    end
  end

  #----------------------------------------------------------------------------
  # is_creator_for_room/2
  #----------------------------------------------------------------------------
  defp is_creator_for_room(room_id, user_id) do
    case Context.get_by(InterestTopic, room_id: room_id) do
      %{created_by_id: created_by} ->
        if user_id == created_by do
          true
        else
          case Context.get_by(UserEvent, group_chat_room_id: room_id) do
            %{user_id: created_by} ->
              if user_id == created_by, do: true, else: false

            _ ->
              false
          end
        end

      _ ->
        case Context.get_by(UserEvent, group_chat_room_id: room_id) do
          %{user_id: created_by} ->
            if user_id == created_by, do: true, else: false

          _ ->
            false
        end
    end
  end

  #----------------------------------------------------------------------------
  # get_message_for_send_email/2
  #----------------------------------------------------------------------------
  def get_message_for_send_email(%{"event" => event} = params) do
    with %NotificationType{} = data <- Context.get_by(NotificationType, event: event),
         message <- PushNotification.make_notification_message(params["keys"], data.message, event) do
      message
    else
      nil -> "You have been invited to join private group"
    end
  end

  #----------------------------------------------------------------------------
  # broadcast_to_chat_listing/4
  #----------------------------------------------------------------------------
  def broadcast_to_chat_listing(sender_user_id, room_data, is_room \\ true, active_users \\ []) do
    #    sender_user_id = "a711bf85-963f-42ed-9728-c2047d5694fb"

    #    this variable to be removed after testing
    #    user_ids = ["a711bf85-963f-42ed-9728-c2047d5694fb"]

    room_data =
      if is_room do
        ApiWeb.Api.V1_0.UserChatView.render("user_room.json", user_room: room_data |> Rooms.preload_all(), current_user_id: sender_user_id)
      else
        room_data = Context.get(Room, room_data.room_id)
        ApiWeb.Api.V1_0.UserChatView.render("user_room.json", user_room: room_data |> Rooms.preload_all(), current_user_id: sender_user_id)
      end

    broadcasting_user_ids = Context.RoomUsers.get_room_user_ids(room_data.room_id) -- active_users

    room_data =
      Api.Plugs.AddImageBaseURL.adding_image_base_url(room_data)
      |> Casex.to_camel_case()

    Enum.map(
      broadcasting_user_ids,
      fn user_id ->
        count = RoomMessageMetas.get_count_of_unread_message(user_id, room_data["roomId"])
        room_data =
          Map.put(room_data, "unreadMessageCount", count)
          |> Map.put("totalUnreadChats", RoomMessageMetas.get_count_of_unread_chats(user_id))

        ApiWeb.Endpoint.broadcast("user:#{user_id}", "user", room_data)
      end
    )
  end

  def broadcast_delete_for_me(user_id, room_data) do
    #    sender_user_id = "a711bf85-963f-42ed-9728-c2047d5694fb"

    #    this variable to be removed after testing
    #    user_ids = ["a711bf85-963f-42ed-9728-c2047d5694fb"]

    room_data = Context.get(Room, room_data.room_id)
    room_data = ApiWeb.Api.V1_0.UserChatView.render("user_room.json", user_room: room_data |> Rooms.preload_all(), current_user_id: user_id)

    room_data =
      Api.Plugs.AddImageBaseURL.adding_image_base_url(room_data)
      |> Casex.to_camel_case()

    count = RoomMessageMetas.get_count_of_unread_message(user_id, room_data["roomId"])
    room_data =
      Map.put(room_data, "unreadMessageCount", count)
      |> Map.put("totalUnreadChats", RoomMessageMetas.get_count_of_unread_chats(user_id))
    ApiWeb.Endpoint.broadcast("user:#{user_id}", "user", room_data)
  end

  #----------------------------------------------------------------------------
  # filter_users/1
  #----------------------------------------------------------------------------
  defp filter_users(user_ids, current_user_id) do
    Enum.flat_map(user_ids, fn user_id ->
      with %User{is_deleted: false, is_deactivated: false, is_self_deactivated: false} = _user <- Context.get(User, user_id),
           false <- UserBlocks.get_blocked_status(current_user_id, user_id) do
            [user_id]
         else
           _ -> []
      end
    end) |> Enum.uniq()
  end
  def make_shareable_link(room) do
    Task.start(fn ->
      sl = Common.generate_url("room", room.id)
      room
      |> Room.changeset(%{shareable_link: sl})
      |> Repo.insert_or_update
    end)
  end
  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      AddRoomUser:
        swagger_schema do
          title("Add User to a room")
          description("Add a User to a Room by their user ID or you can send array with key user_ids")

          properties do
            user_id(:string, "User ID")
            room_id(:string, "Room ID")
          end

          example(%{
            user_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
            room_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa"
          })
        end,
      DeleteRoomUser:
        swagger_schema do
          title("Delete User from a room")
          description("Remove a User from a Room by their user IDs")

          properties do
            user_id(:string, "User ID")
            room_id(:string, "Room ID")
          end

          example(%{
            user_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
            room_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa"
          })
        end,
      AddUserToChat:
        swagger_schema do
          title("Add User to a chat")
          description("Add a User to a chat by their email ID")

          example(%{
            responseData: %{
              user_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
              first_name: "first name",
              last_name: "last name",
              image_name: "User Image",
              room_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa"
            }
          })
        end,
      DeleteRoomMessage:
        swagger_schema do
          title("Delete Chat Message")
          description("Delete Chat Message")

          properties do
            room_message_list(:array, "room_message_ids")
          end

          example(%{
            room_message_ids: [
              "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
              "2cfd8787-315b-4f1b-8c50-83f2a14d3f1a"
            ]
          })
        end,
      DeleteUserFromChat:
        swagger_schema do
          title("Delete User from a chat")
          description("Remove a User from a chat by their ID and Room ID")

          example(%{
            responseData: %{
              user_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
              first_name: "first name",
              last_name: "last name",
              image_name: "User Image",
              room_id: "215f1fb5-69ee-4f53-a81f-c277c3f048fa"
            }
          })
        end,
      Users:
        swagger_schema do
         title("List of Users")
         description("List of Users")
         example(%{
           responseData: %{
             data: [
               %{
               firstName: "test",
               lastName: "user",
               userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
               userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
               baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              },
              %{
               firstName: "test",
               lastName: "user",
               userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
               userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
               baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
             }
            ],
             pagination: %{
               page: 1,
               totalPages: 1,
               totalRows: 2
             }
          }
        })
       end,
      ChatMessage:
        swagger_schema do
          title("Comments or Messages by Room ID")
          description("Comments or Messages By Room ID")

          example(%{
            responseData: %{
              data: [
                %{
                  message: "here is a message",
                  messageId: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
                  messageImages: [],
                  callbackVerification: "here we go",
                  user: %{
                    firstName: "test",
                    lastName: "user",
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                },
                %{
                  message: "Here is a message",
                  messageId: "215f1fb5-69ee-4f53-a81f-c277c3f048fa",
                  messageImages: [],
                  callbackVerification: "here we go",
                  user: %{
                    firstName: "test",
                    lastName: "user",
                    userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                    userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                }
              ],
              pagination: %{
                page: 1,
                totalPages: 1,
                totalRows: 2
              }
            }
          })
        end,
      UserChatRoom:
        swagger_schema do
          title("Chat messages")
          description("Chat messages")

          example(%{
            ResponseData: %{
              chatMessages: %{
                data: [
                  %{
                    message: "",
                    messageId: "3dac012f-e4f7-4f27-9745-1567af719eea",
                    messageImages: [],
                    messageTime: "2021-12-23T09:50:48Z",
                    callbackVerification: "here we go",
                    user: %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: nil
                    }
                  },
                  %{
                    message: "",
                    messageId: "3dac012f-e4f7-4f27-9745-1567af719ecb",
                    messageImages: [],
                    messageTime: "2021-12-23T09:50:48Z",
                    callbackVerification: "here we go",
                    user: %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694ab",
                      userImage: nil
                    }
                  }
                ],
                pagination: %{
                  page: 1,
                  totalPages: 1,
                  totalRows: 2
                }
              },
              roomId: "de856c10-b458-49de-ba1d-71a95ca6acb7",
              roomUsers: [
                %{
                  firstName: "",
                  lastName: "",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  userImage: nil
                },
                %{
                  firstName: "",
                  lastName: "",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fc",
                  userImage: nil
                }
              ]
            }
          })
        end,
      StartUserChat:
        swagger_schema do
          title("Start User Chat")
          description("Start User Chat, chat user_id")

          properties do
            user_id(:string, "User ID to chat with")
            referral_code(:string, "Room custom Referral code")
          end

          example(%{
            user_id: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85"
          })
        end,
      SendInvite:
        swagger_schema do
          title("Start User Chat")
          description("Start User Chat, chat user_id with room_id t0 get chats of a room")

          properties do
            email(:string, "test1@gmail.com")
            referral_code(:string, "Referral Code of Room")
          end

          example(%{
            email: "test1@gmail.com",
            referral_code: "AXDFEWS"
          })
        end,
      AddInvitedUser:
        swagger_schema do
          title("Add Invited User")
          description("Add Invited user in Room")

          properties do
            user_id(:string, "test1@gmail.com")
            referral_code(:string, "Referral Code of Room")
            response(:boolean, true)
          end

          example(%{
            user_id: "b6a25b95-f0a9-42c5-a41d-35893f099adf",
            referral_code: "AXDFEWS",
            response: true
          })
        end,
      UserChatRoomsList:
        swagger_schema do
          title("Chat Rooms")
          description("Chat Rooms")

          example(%{
            ResponseData: %{
              userChats: [
                %{
                  lastMessage: %{
                    message: "",
                    messageId: "546cc1e4-6970-4182-9094-ed9f0921ecd8",
                    messageImages: [],
                    callbackVerification: "here we go",
                    messageTime: "2021-12-24T10:09:58Z",
                    user: %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: nil
                    }
                  },
                  roomId: "2f0226ca-ea83-492f-b209-08d4f9c45d6b",
                  roomType: "event_chat",
                  roomUsers: [
                    %{
                      firstName: "",
                      lastName: "",
                      userId: "d68bbf19-98d0-4b4b-84b6-3cf94e89113c",
                      userImage: nil
                    },
                    %{
                      firstName: "",
                      lastName: "",
                      userId: "fa11b37c-46d7-4749-bb88-46b26820ea69",
                      userImage:
                        "https://d1exz3ac7m20xz.cloudfront.net/images/user-profile-images/user-4ade59c9-e6a6-46cf-95e9-1aee9a94a8fa.jpg"
                    },
                    %{
                      firstName: "",
                      lastName: "",
                      userId: "98a62112-5e2f-4947-8c85-0542f00a7eb5",
                      userImage:
                        "https://d1exz3ac7m20xz.cloudfront.net/images/user-profile-images/user-4ade59c9-e6a6-46cf-95e9-1aee9a94a8fa.jpg"
                    }
                  ],
                  userEvent: %{
                    description: "",
                    eventEndDate: "",
                    eventEndTime: nil,
                    eventStartDate: "",
                    eventStartTime: nil,
                    formatedAddress: "",
                    id: "1528b8c7-3893-4897-9b9c-75bc8ad357bf",
                    image: "",
                    interestId: "1f73cf94-6c64-410b-9428-0e7c75007f33",
                    interestName: "",
                    latitude: 00.000000,
                    longitude: 00.000000,
                    roomId: "",
                    user: %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: nil
                    }
                  }
                },
                %{
                  lastMessage: %{
                    message: "",
                    messageId: "49abe8fa-fb4d-4a38-8752-9b0f135e4c15",
                    messageImages: [],
                    callbackVerification: "here we go",
                    messageTime: "2021-12-24T09:57:39Z",
                    user: %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: nil
                    }
                  },
                  roomId: "de856c10-b458-49de-ba1d-71a95ca6acb7",
                  roomType: "user_chat",
                  roomUsers: [
                    %{
                      firstName: "",
                      lastName: "",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: nil
                    },
                    %{
                      firstName: "",
                      lastName: "",
                      userId: "8293b415-a13c-4a36-a117-5a6b8db2af9c",
                      userImage: nil
                    }
                  ],
                  userEvent: nil
                }
              ]
            }
          })
        end,
      ChatRoomInListing:
        swagger_schema do
          title("Chat Room in Listing")
          description("Chat Room in Listing")

          example(%{
            ResponseData: %{
              lastMessage: %{
                message: "",
                messageId: "546cc1e4-6970-4182-9094-ed9f0921ecd8",
                messageImages: [],
                messageTime: "2021-12-24T10:09:58Z",
                callbackVerification: "here we go",
                user: %{
                  firstName: "",
                  lastName: "",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  userImage: nil
                }
              },
              roomId: "2f0226ca-ea83-492f-b209-08d4f9c45d6b",
              roomType: "event_chat",
              imageName: "room/d510cd5c-255d-4f11-81dd-841a1310b599.jpg",
              roomUsers: [
                %{
                  firstName: "",
                  lastName: "",
                  userId: "d68bbf19-98d0-4b4b-84b6-3cf94e89113c",
                  userImage: nil
                },
                %{
                  firstName: "",
                  lastName: "",
                  userId: "fa11b37c-46d7-4749-bb88-46b26820ea69",
                  userImage:
                    "https://d1exz3ac7m20xz.cloudfront.net/images/user-profile-images/user-4ade59c9-e6a6-46cf-95e9-1aee9a94a8fa.jpg"
                }
              ]
            }
          })
        end,
      StartGroupChat:
        swagger_schema do
          title("Start Group Chat")
          description("Start chatting within in a group")

          properties do
            user_ids(:array, "User ID to chat with")
            group_name(:string, "Group name")
            image(:string, "base64 image")
          end
          example(%{
            user_ids: ["41efe64a-5c2e-4d6b-a6d3-a534b2a58e85", "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85"],
            group_name: "Jetzy",
            image: "image/jpeg;base64,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"
          })
        end,
      UpdateGroupChat:
        swagger_schema do
          title("Update Group Chat")
          description("Update settings for a chat group")

          properties do
            group_name(:string, "Group name")
            referral_code(:string, "Referral Code")
            image(:string, "base64 image")
          end
          example(%{
            group_name: "Jetzy",
            image: "image/jpeg;base64,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"
          })
        end,
      GroupDetail: swagger_schema do
        title("Room's short details")
        description("Room's short details")
        example(%{
        room_id: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85",
        room_type: "group-chat",
        group_name: "Jetzy",
        image: "",
        totalUsers: 10,
        roomUsers: [
          %{
          isActive: false,
          userId: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85",
          firstName: "Tim",
          lastName: "Adam",
          userImage: "",
          roomId: "60980848-64db-4f6f-a522-4ac9374a7d40",
          referralCode: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85"
        },
          %{
            isActive: false,
            userId: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85",
            firstName: "Tim",
            lastName: "John",
            userImage: "",
            roomId: "60980848-64db-4f6f-a522-4ac9374a7d40",
            referralCode: "41efe64a-5c2e-4d6b-a6d3-a534b2a58e85"
          }
        ]
        })
      end,
      MakeAdmin: swagger_schema do
        title("Make Admin Api Respone")
        description("Make Admin Api Respone")
        example(%{message: "User is now admin"})
      end,
      UserGroups: swagger_schema do
        title("Users for chat")
        description("In case of no room_id catagorized users according to follow following interests")
        example(%{
          "ResponseData": %{
            "suggested": %{
              "pagiation": %{
                "totalRows": 3,
                "totalPages": 1,
                "page": 1
              },
              "data": [
                %{
                  "users": [
                    %{
                      "userImage": "user/cefab2b6-9fc1-461a-b1ff-4d53c44df94d.jpg",
                      "userId": "86162497-4fac-407d-be0e-7d7541ffb39b",
                      "lastName": "abid",
                      "isGroupMember": false,
                      "isActive": false,
                      "imageThumbnail": "user/cefab2b6-9fc1-461a-b1ff-4d53c44df94d_thumb.jpg",
                      "firstName": "talha",
                      "blurHash": nil,
                      "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    %{
                      "userImage": "user/c6da31b7-0a7e-4389-a5d5-351b5d6dea9a.jpg",
                      "userId": "c2be9437-8f5b-4d48-8d7f-f57971109df5",
                      "lastName": "aleem",
                      "isGroupMember": false,
                      "isActive": false,
                      "imageThumbnail": "user/c6da31b7-0a7e-4389-a5d5-351b5d6dea9a_thumb.jpg",
                      "firstName": "saqib",
                      "blurHash": nil,
                      "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  "interestName": "Beach Bum",
                  "interestId": "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c"
                },
                %{
                  "users": [],
                  "interestName": "Business Traveler",
                  "interestId": "41fe4093-5be0-434f-9db6-82ceb9f91948"
                },
                %{
                  "users": [
                    %{
                      "userImage": "user/c6da31b7-0a7e-4389-a5d5-351b5d6dea9a.jpg",
                      "userId": "c2be9437-8f5b-4d48-8d7f-f57971109df5",
                      "lastName": "aleem",
                      "isGroupMember": false,
                      "isActive": false,
                      "imageThumbnail": "user/c6da31b7-0a7e-4389-a5d5-351b5d6dea9a_thumb.jpg",
                      "firstName": "saqib",
                      "blurHash": nil,
                      "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  "interestName": "Clubber",
                  "interestId": "1f73cf94-6c64-410b-9428-0e7c75007f33"
                }
              ]
            },
            "following": %{
              "pagiation": %{
                "totalRows": 3,
                "totalPages": 1,
                "page": 1
              },
              "data": [
                %{
                  "userImage": "user/f61fec8d-4bb4-4058-9b61-0737c43b5bdf.jpg",
                  "userId": "456809aa-0aa0-4d30-a446-a9d7b323e93f",
                  "lastName": "afzal",
                  "isGroupMember": false,
                  "isActive": false,
                  "imageThumbnail": "user/f61fec8d-4bb4-4058-9b61-0737c43b5bdf_thumb.jpg",
                  "firstName": "baqar",
                  "blurHash": nil,
                  "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  "userImage": "user/500930cd-e5fc-44d1-b69c-54544c3dccd0.jpg",
                  "userId": "1587d0f7-0fa9-411f-b592-96f1e78ddcf4",
                  "lastName": "javed",
                  "isGroupMember": false,
                  "isActive": false,
                  "imageThumbnail": "user/500930cd-e5fc-44d1-b69c-54544c3dccd0_thumb.jpg",
                  "firstName": "muneeb",
                  "blurHash": nil,
                  "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  "userImage": "user/4dabcebc-c05d-423b-894d-c8400427fbef.jpg",
                  "userId": "e00262f3-51a6-4ed3-bf96-62dde98980db",
                  "lastName": "name",
                  "isGroupMember": false,
                  "isActive": false,
                  "imageThumbnail": "user/4dabcebc-c05d-423b-894d-c8400427fbef_thumb.jpg",
                  "firstName": "test",
                  "blurHash": nil,
                  "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ]
            },
            "followers": %{
              "pagiation": %{
                "totalRows": 0,
                "totalPages": 1,
                "page": 1
              },
              "data": [
                %{
                  "userImage": "user/500930cd-e5fc-44d1-b69c-54544c3dccd0.jpg",
                  "userId": "1587d0f7-0fa9-411f-b592-96f1e78ddcf4",
                  "lastName": "javed",
                  "isGroupMember": false,
                  "isActive": false,
                  "imageThumbnail": "user/500930cd-e5fc-44d1-b69c-54544c3dccd0_thumb.jpg",
                  "firstName": "muneeb",
                  "blurHash": nil,
                  "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  "userImage": "user/4dabcebc-c05d-423b-894d-c8400427fbef.jpg",
                  "userId": "e00262f3-51a6-4ed3-bf96-62dde98980db",
                  "lastName": "name",
                  "isGroupMember": false,
                  "isActive": false,
                  "imageThumbnail": "user/4dabcebc-c05d-423b-894d-c8400427fbef_thumb.jpg",
                  "firstName": "test",
                  "blurHash": nil,
                  "baseUrl": "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ]
            }
          }
        })
      end

    }
  end
end
