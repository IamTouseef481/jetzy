defmodule ApiWeb.UserChannel do
  use ApiWeb, :channel
  require Logger
  alias Data.Context
#  alias Data.Context.RoomUsers
  alias Data.Schema.User
#  alias Data.Schema.{User, Room, RoomMessage, RoomMessageMeta, RoomMessageImage}

  def join("user:" <> user_id, _params, socket) do
    with {:ok, _} <- UUID.info(user_id),
         %User{} <- Context.get(User, user_id),
         true <- socket.assigns.current_user.id == user_id do
      send(self(), :after_join)
      {:ok, socket}
    else
      nil -> {:error, %{message: "Incorrect User Id"}}
      false -> {:error, %{message: "Some Other User is trying to Connect"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
  end

  


  def handle_info(:after_join, socket) do
    # Hack - auto join user to backend channel
    Logger.warn("Forcing user to automatically join additional channels")
    msg = %{topic:  "backend:#{socket.assigns.current_user.id}", payload: %{}, ref: make_ref(), join_ref: nil}
    Phoenix.Channel.Server.join(socket, ApiWeb.BackendChannel, msg, []) |> IO.inspect(label: :join_outcome)
    #------------------
    {:noreply, socket}
  end
  
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("heartbeat", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("phx_close", _payload, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

#  def handle_out("user", msg, socket) do
#    push(socket, "user", msg)
#    {:noreply, socket}
#  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end
end
  