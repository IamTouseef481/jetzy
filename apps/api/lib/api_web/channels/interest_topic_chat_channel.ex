defmodule ApiWeb.InterestTopicChatChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Context.{RoomUsers, Interests, RoomMessageMetas}
  alias Data.Schema.{UserInterestMeta, Room, RoomMessage, RoomMessageImage}
  alias ApiWeb.EventCommentChannel
  alias ApiWeb.Presence
  alias ApiWeb.Utils.Common
  alias JetzyModule.AssetStoreModule, as: AssetStore

  def join("interest_topic_chats:" <> room_id, _params, socket) do
    with {:ok, _} <- UUID.info(room_id),
         %Room{room_type: "interest_topic_chat"} = _room <- Context.get(Room, room_id),
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
      %Room{} -> {:error, %{message: "Not an interest topic chat channel room id"}}
      false -> {:error, %{message: "You are not member of this Room"}}
      nil -> {:error, %{message: "Incorrect Room"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
  end

  def handle_in("chat", payload, socket) do
    "interest_topic_chats:" <> room_id = socket.topic

    payload =
      Map.merge(payload, %{"room_id" => room_id, "sender_id" => socket.assigns.current_user.id})
    with true <- Common.check_message(payload["message"], "chat", payload["messageImages"]),
         {:ok, room_message} <- Context.create(RoomMessage, payload),
         :ok <- RoomMessageMetas.populate_room_message_meta(room_id, room_message.id, socket.assigns.current_user.id, Presence.get_active_users(socket.topic)) do
        update_user_interest_meta(payload)
        images =
          if is_nil(payload["messageImages"]) do
            []
          else
            payload["messageImages"]
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
        response = EventCommentChannel.make_message_socket_response(payload, socket.assigns.current_user.id, images, room_message)
        ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(socket.assigns.current_user.id, room_message, false)
        broadcast(socket, "chat", response)
        {:noreply, socket}
      else
      {:error, error} -> {:reply, {:error, error}, socket}
      _ ->
        {:error, %{message: "Something went wrong"}}
    end

  end

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def handle_in("heartbeat", payload, socket) do
    {:reply, {:ok, payload}, socket}
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

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def update_user_interest_meta(%{"interest_id" => interest_id}) when not is_nil(interest_id) do
    case Interests.get_user_interest_meta(interest_id) do
      nil -> nil
      data ->
        Context.update(UserInterestMeta, data, %{last_message_at: DateTime.utc_now()})
    end
  end
  def update_user_interest_meta(payload), do: payload

  defp send_broadcast_to_room(room_id) do
    ApiWeb.Endpoint.broadcast(
      "interest_topic_chats:" <> room_id,
      "all_messages_seen",
      %{
        room_id: room_id,
        seen: true
      }
    )
  end

end
  