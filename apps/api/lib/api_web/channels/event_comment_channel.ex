defmodule ApiWeb.EventCommentChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Context.{UserEvents, RoomUsers, RoomMessages}
  alias Data.Schema.{Room, RoomMessage, RoomMessageMeta, RoomUser, RoomMessageImage, User}
  alias ApiWeb.Utils.Common
  alias JetzyModule.AssetStoreModule, as: AssetStore
  alias ApiWeb.Presence



  def join("event_comments:" <> room_id, _params, socket) do
    with {:ok, _} <- UUID.info(room_id),
         %Room{room_type: "event_comments"} = _room <- Context.get(Room, room_id),
         false <- RoomUsers.user_exists_in_room(room_id, socket.assigns.current_user.id),
         {:ok, _room_user} <- Context.create(RoomUser, %{room_id: room_id, user_id: socket.assigns.current_user.id}) do
      send(self(), :after_join)
      {:ok, socket}
    else
      true ->
        send(self(), :after_join)
        {:ok, socket}
        %Room{} -> {:error, %{message: "Not a comment channel room id"}}
      {:error, _} -> {:error, %{message: "Error in Creating Room Member!"}}
      nil -> {:error, %{message: "Incorrect Room"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
  end

  def handle_in("comment", payload, socket) do
    "event_comments:" <> room_id = socket.topic
    current_user_id = socket.assigns.current_user.id
    first_name = if is_nil(socket.assigns.current_user.first_name), do: "", else: socket.assigns.current_user.first_name
    last_name = if is_nil(socket.assigns.current_user.last_name), do: "", else: socket.assigns.current_user.last_name

    payload =
      Map.merge(payload, %{"room_id" => room_id, "sender_id" => current_user_id})
    with true <- Common.check_message(payload["message"], "comment", payload["messageImages"]),
         true <- RoomUsers.user_exists_in_room(room_id, current_user_id),
          %RoomMessage{} = parent_message <- payload["parent_id"] && check_parent_id(payload["parent_id"]) || %RoomMessage{},
         {:ok, room_message} <- Context.create(RoomMessage, payload),
         {:ok, _} <- Context.create(RoomMessageMeta, %{room_message_id: room_message.id, user_id: current_user_id, room_id: room_id}) do
      %{user_id: event_created_by_id, id: event_id} = user_event = UserEvents.get_user_event_by_room_id(room_message.room_id)
      if Map.has_key?(payload, "tags") do
        send_push_notification_for_comment_tagging(payload["tags"], event_id, first_name <> last_name, current_user_id)
      end
      case parent_message do
        %RoomMessage{id: nil} ->
          # room_users = RoomUsers.get_room_user_ids(room_message.room_id)
          # Enum.map(room_users, fn user_id ->
          #   if current_user_id != user_id do
          #     case Context.get(User, user_id) do
          #       %User{is_deleted: false, is_deactivated: false} = _user ->
          #         push_notification_params_for_room_users = %{
          #           "keys" => %{
          #             "first_name" => socket.assigns.current_user.first_name,
          #             "last_name" => socket.assigns.current_user.last_name
          #           },
          #           "event" => "event_comments",
          #           "user_id" => user_id,
          #           "sender_id" => current_user_id,
          #           "type" => "event_comments",
          #           "resource_id" => event_id,
          #           "owner_id" => event_created_by_id
          #         }
          #         ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params_for_room_users)
          #       _ -> :ok
          #     end
          #   end
          # end)
          if current_user_id != event_created_by_id do
            case Context.get(User, event_created_by_id) do
              %User{is_deleted: false, is_deactivated: false} = _user ->
                push_notification_params_for_room_users = %{
                  "keys" => %{
                    "first_name" => socket.assigns.current_user.first_name,
                    "last_name" => socket.assigns.current_user.last_name
                  },
                  "event" => "event_comments",
                  "user_id" => event_created_by_id,
                  "sender_id" => current_user_id,
                  "type" => "event_comments",
                  "resource_id" => event_id,
                  "owner_id" => event_created_by_id
                }
                ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params_for_room_users)
              _ -> :ok
            end
          end

          %RoomMessage{sender_id: owner_id} ->
          if current_user_id != owner_id do
            push_notification_params_for_room_users = %{
              "keys" => %{
                "first_name" => socket.assigns.current_user.first_name,
                "last_name" => socket.assigns.current_user.last_name
              },
              "event" => "feed_shoutout_comment_reply",
              "user_id" => owner_id,
              "sender_id" => current_user_id,
              "type" => "feed_shoutout_comment_reply",
              "resource_id" => event_id,
              "owner_id" => event_created_by_id
            }
            ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params_for_room_users)
          end
      end
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
      response = make_message_socket_response(payload, current_user_id, images, room_message)
      ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(current_user_id, room_message, false)
      broadcast(socket, "comment", response)
      Common.broadcast_for_comment("user_profile:#{event_created_by_id}", user_event, response["commentsCount"])
      Common.broadcast_for_comment("jetzy_timeline", user_event, response["commentsCount"])
      {:noreply, socket}
    else
      false ->
#        {:error, %{message: "User is not allowed to comment"}}
        push(socket, "error", %{message: "User is not allowed to comment"})
        {:noreply, socket}
      :not_exist ->
        push(socket, "error", %{message: "Comment does'nt exist"})
        {:noreply, socket}
        {:error, error} -> {:reply, {:error, error}, socket}
      _ ->
#        {:error, %{message: "Something went wrong"}}
        push(socket, "error", %{message: "Something went wrong"})
        {:noreply, socket}
    end
  end
  def send_push_notification_for_comment_tagging(comment_tags_list, event_id, name, user_id) do
    Enum.each(comment_tags_list, fn comment_tags ->
      params_for_comment_tagging_push = %{"keys" => %{name: name},
      "event" => "comment_tagging", "user_id" => comment_tags["user_id"], "sender_id" => user_id, "type" => "comment_tagging", "resource_id" => event_id}
    ApiWeb.Utils.PushNotification.send_push_notification(params_for_comment_tagging_push)
    end)
  end

  def handle_in("edit_comment", payload, socket) do
    current_user_id = socket.assigns.current_user.id
    with true <- Common.check_message(payload["message"], "comment", payload["messageImages"]),
         %RoomMessage{} = data <- Context.get(RoomMessage, payload["comment_id"]),
         {:ok, updated_message} <- Context.update(RoomMessage, data, %{message: payload["message"]}) do
        response = make_message_socket_response(payload, current_user_id, [], updated_message)
      ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(current_user_id, updated_message, false)
      broadcast(socket, "edit_comment", response)
      {:noreply, socket}
    else
      nil ->
        push(socket, "error", %{message: "No room message found"})
        {:noreply, socket}
      {:error, %Ecto.Changeset{}} ->
        push(socket, "error", %{message: "unable to update room message"})
        {:noreply, socket}
        {:error, error} -> {:reply, {:error, error}, socket}
      _ ->
        push(socket, "error", %{message: "Something went wrong"})
        {:noreply, socket}
    end
  end

  def handle_in("leave_channel", _payload, socket) do
    Presence.untrack(socket, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  def handle_in("heartbeat", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.current_user.id, %{
      online_at: inspect(System.system_time(:second))
    })
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def make_message_socket_response(payload, sender_id, images, room_message) do
    image_bucket = JetzyModule.AssetStoreModule.image_bucket()
    base_url = JetzyModule.AssetStoreModule.image_base_url()
    sender = Context.get(User, sender_id)
    if is_nil(images)do
      Map.put(payload, "messageImages", images)
    else
      Map.merge(payload, %{"messageImages" => images,
        "baseUrl" => "https://#{base_url}/"})
    end
    |> Map.drop(["sender_id", "room_id", "images", "callback_verification", "comment_id"])
    |> Map.merge(%{"messageTime" => room_message.inserted_at,
      "messageId" => room_message.id,
      "callbackVerification" => room_message.callback_verification,
      "parentId" => room_message.parent_id,
      "commentsCount" => RoomMessages.count_room_messages(room_message.room_id)
    })
    |> Map.put("user",
      %{
        "isActive" => sender && sender.is_active,
        "userImage" => sender && sender.image_name,
        "userId" => sender && sender.id,
        "lastName" => sender && sender.last_name,
        "firstName" => sender && sender.first_name,
        "baseUrl" => "https://#{base_url}/",
      })
  end

  def check_parent_id(parent_id) do
  case Data.Context.get(RoomMessage, parent_id) do
    %RoomMessage{} = room_message -> room_message
    nil -> :not_exist
  end
  end

  def handle_out("comment", msg, socket) do
    push(socket, "comment", msg)
    {:noreply, socket}
  end

  def handle_out("edit_comment", msg, socket) do
    push(socket, "edit_comment", msg)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end
end
