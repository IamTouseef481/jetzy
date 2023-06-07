defmodule ApiWeb.NotificationChannel do
  use ApiWeb, :channel
  require Logger
  alias Data.Schema.User
  alias Data.Context
  alias Data.Context.{NotificationsRecords}
  alias ApiWeb.Presence

  def join("notification:" <> user_id, _params , socket) do
    with {:ok, _} <- UUID.info(user_id),
         %User{}  <- Context.get(User, user_id),
         true <- socket.assigns.current_user.id == user_id do
      send(self(), :after_join)
      NotificationsRecords.update_notifications_opened_status(user_id)
      broadcast_to_user(user_id)
      {:ok, socket}
    else
      nil -> {:error, %{message: "Incorrect User Id"}}
      false -> {:error, %{message: "Some Other User is trying to Connect"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
  end

  def handle_in("leave_channel", _payload, socket) do
    Presence.untrack(socket, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  def handle_in("heartbeat", payload, socket) do
    {:reply, {:ok, payload}, socket}
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

  defp broadcast_to_user(user_id) do
    ApiWeb.Endpoint.broadcast(
      "user:" <> user_id,
      "unread_notification_count",
      %{
        unread_notification_count:
          NotificationsRecords.get_unread_notifications_count(user_id)
      }
    )
  end
end
