defmodule ApiWeb.UserProfileChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Schema.User

  def join("user_profile:" <> user_id, _params, socket) do
    with {:ok, _} <- UUID.info(user_id),
         %User{} <- Context.get(User, user_id) do
      {:ok, socket}
    else
      nil -> {:error, %{message: "Incorrect User Id"}}
      _ -> {:error, %{message: "Not able to Join Room"}}
    end
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

  def handle_in("phx_leave", _payload, socket) do
    {:stop, {:shutdown, :left}, socket}
  end

  def terminate(_reason, socket) do
    {:stop, {:shutdown, :closed}, socket}
  end

end