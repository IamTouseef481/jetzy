defmodule ApiWeb.UserChatChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Context.{RoomUsers, RoomMessageMetas, UserBlocks, RoomMessages}
  alias Data.Schema.{Room, RoomMessage, RoomMessageImage, User, UserBlock, RoomMessageMeta}
  alias ApiWeb.EventCommentChannel
  alias ApiWeb.Presence
  alias ApiWeb.Utils.Common
  alias JetzyModule.AssetStoreModule, as: AssetStore

  def join("chats:" <> room_id, _params, socket) do

    with {:ok, _} <- UUID.info(room_id),
         %Room{} = room <- Context.get(Room, room_id),
         :valid   <- room.room_type in ["user_chat", "event_chat", "group_chat"] && :valid || :invalid,
         true <- RoomUsers.user_exists_in_room(room_id, socket.assigns.current_user.id) do
      case RoomMessageMetas.update_message_read_status(socket.assigns.current_user.id, room_id) do
        {0, nil} -> :ok
        _ ->
          if RoomMessageMetas.all_room_users_read_message?(room_id) do
            send_broadcast_to_room(room_id)
          end
      end
      send(self(), :after_join)
      {:ok, socket}
    else
      :invalid -> {:error, %{message: "Not a chat room id"}}
      false -> {:error, %{message: "You are not member of this Room"}}
      nil -> {:error, %{message: "Incorrect Room"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
  end

  def handle_in("chat", payload, socket) do
    "chats:" <> room_id = socket.topic

    #---------------needed to take this id in payloads in separate key-------------
    updated_payload = case payload do
      %{"message" => message} when is_binary(message) ->
        message = case String.split(message, "###") do
          [_, message] -> message
          [message] -> message
        end
        Map.merge(payload, %{"message" => message})
      payload -> payload
    end
#---------------needed to take this id in payloads in separate key-------------

    room = Context.get(Room, room_id)
    updated_payload =
      Map.merge(updated_payload, %{"room_id" => room_id, "sender_id" => socket.assigns.current_user.id})
    with true <- Common.check_message(updated_payload["message"], "chat", updated_payload["messageImages"]),
         {:ok, _} <- validate_room(room, socket.assigns.current_user.id),
         :not_exists <- RoomMessages.verify_callback_verification(updated_payload["callback_verification"]),
         {:ok, room_message} <- Context.create(RoomMessage, updated_payload),
    :ok <- RoomMessageMetas.populate_room_message_meta(room_id, room_message.id, socket.assigns.current_user.id, Presence.get_active_users(socket.topic)) do
      #In case if any of the user deleted the chat, we'll set deleted_by as nil. So both of them can get messages
      room = case room do
        %Room{deleted_by: nil} = room -> room
        room ->
      {:ok, room} = Context.update(Room, room, %{deleted_by: nil})
      room
      end
      images =
          if is_nil(updated_payload["messageImages"]) do
            []
          else
            updated_payload["messageImages"]
            |> Enum.with_index(1)
            |> Enum.map(fn {image, _key} ->
              {:ok, img_url} =
                AssetStore.upload_image(
                  image,
                  "room_message"
                )

              Context.create(RoomMessageImage, %{
                image: img_url,
                room_message_id: room_message.id
              })

              img_url
            end)
          end
        response = updated_payload
          |> Map.merge(%{"message" => payload["message"]})
          |> EventCommentChannel.make_message_socket_response(socket.assigns.current_user.id, images, room_message)
        ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(socket.assigns.current_user.id, room_message, false)
        active_users = Presence.get_active_users(socket.topic)
        room_users = RoomUsers.get_room_user_ids(room_id)
        valid_users_for_sending_push = room_users -- active_users
      %User{first_name: first_name, last_name: last_name} = Context.get(User, socket.assigns.current_user.id)
      push_notification_params =
        cond do
          room.room_type == "user_chat" ->
            %{
              "keys" => %{ "first_name" => first_name, "last_name" => last_name }, "event" => "incoming_message", "title" => make_full_name_string(first_name, last_name),
              "sender_id" => socket.assigns.current_user.id, "resource_id" => room.id }
        room.room_type == "group_chat" ->
          %{
            "keys" => %{ "first_name" => first_name, "last_name" => last_name, "room_name" => room.group_name }, "event" => "incoming_group_message", "title" => room.group_name || "group",
            "sender_id" => socket.assigns.current_user.id, "resource_id" => room.id }
        room.room_type == "event_chat" ->
          %{
            "keys" => %{ "first_name" => first_name, "last_name" => last_name, "room_name" => room.group_name }, "event" => "incoming_event_message", "title" => room.group_name || "private event group",
            "sender_id" => socket.assigns.current_user.id, "resource_id" => room.id }
      end

        ApiWeb.Utils.PushNotification.send_push_to_users(valid_users_for_sending_push, push_notification_params)
        # {:ok, room} = update_room_last_message_at(room)
        Task.async(Context, :update, [Room, room, %{last_message_at: DateTime.utc_now}])
        broadcast(socket, "chat", response)
        {:noreply, socket}
      else

      # Here if the room is of type user_chat and one of the user has blocked to other
      # then who has blocked cannot send message
      # But the other one can send message to room, but it will only visible to him/her
      # Any message or notification will not be sent to other user
      :blocked_by_other ->

       with {:ok, room_message} <- Context.create(RoomMessage, updated_payload),
      _  <- Context.create(RoomMessageMeta, %{room_id: room_id, room_message_id: room_message.id, user_id: socket.assigns.current_user.id, is_read: true}) do
         images =
           if is_nil(updated_payload["messageImages"]) do
             []
           else
             updated_payload["messageImages"]
             |> Enum.with_index(1)
             |> Enum.map(fn {image, _key} ->
               {:ok, img_url} =
                 AssetStore.upload_image(
                   image,
                   "room_message"
                 )

               Context.create(RoomMessageImage, %{
                 image: img_url,
                 room_message_id: room_message.id
               })

               img_url
             end)
           end
         response = updated_payload
                    |> Map.merge(%{"message" => payload["message"]})
                    |> EventCommentChannel.make_message_socket_response(socket.assigns.current_user.id, images, room_message)
         push(socket, "chat", response)
         {:noreply, socket}
         else
         _ -> {:reply, {:error, "Something went wrong"}, socket}
        end

      {:error, error} -> {:reply, {:error, error}, socket}
      :exists ->
        send_broadcast_to_user(socket.assigns.current_user.id, "message_dilivery", %{status: "already sent"})
        {:noreply, socket}
      _ -> {:error, %{message: "Something went wrong"}}
    end
  end

  def make_full_name_string(first_name, last_name) do
    cond do
      is_nil(first_name) && is_nil(last_name) -> "Someone"
      is_nil(first_name) -> last_name
      is_nil(last_name) -> first_name
      true -> first_name <> " " <> last_name
    end
  end

  def handle_in("heartbeat", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("phx_close", _payload, socket) do
    Presence.untrack(socket, socket.assigns.current_user.id)
    {:stop, {:shutdown, :closed}, socket}
  end

  def handle_in("leave_channel", _payload, socket) do
    Presence.untrack(socket, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  def handle_out("chat", msg, socket) do
    push(socket, "chat", msg)
    {:noreply, socket}
  end
  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.current_user.id, %{
      online_at: inspect(System.system_time(:second))
    })
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_info(event, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Presence.untrack(socket, socket.assigns.current_user.id)
    {:stop, {:shutdown, :closed}, socket}
  end

  defp validate_room(room, current_user_id) do
    case room.room_type do
       "user_chat" ->
          room_user_ids = RoomUsers.get_room_user_ids(room.id)
          receiver_id = room_user_ids -- [current_user_id]
          if receiver_id == [] do
             {:ok, "Ok"}
             else
             [user_id | _] = receiver_id
            case UserBlocks.get_blocked_status(user_id, current_user_id) do
               true ->
               cond do
                 Context.get_by(UserBlock, [user_from_id: current_user_id, user_to_id: user_id]) != nil ->
                   {:error, "Could not send message"}
                   true ->
                     :blocked_by_other
               end
               _ ->
                 #                 user = Data.Repo.get(Data.Schema.User, current_user_id) || %Data.Schema.User{id: current_user_id}
                 #                 case Data.Schema.User.quick_chat_settings(user_id, user) do
                 #                   %{enabled: true} -> {:ok, "Status Ok"}
                 #                   %{message: m} -> {:error, m || "Activity Restricted"}
                 #                 end
                 # Allow back and forth chats once initiated, to proceed even if follow status has changed since messaging has begun.
                 {:ok, "Status Ok"}
            end
          end
       _ -> {:ok, "Status Ok"}
    end
  end

  defp send_broadcast_to_room(room_id) do
      ApiWeb.Endpoint.broadcast(
        "chats:" <> room_id,
        "all_messages_seen",
        %{
          room_id: room_id,
          seen: true })
  end

  defp send_broadcast_to_user(user_id, message, payload) do
    ApiWeb.Endpoint.broadcast(
      "user:" <> user_id,
      message,
      payload
    )
  end
end
