defmodule ApiWeb.JetzyTimelineChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Schema.User

  def join("jetzy_timeline", _params, socket) do
      {:ok, socket}
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