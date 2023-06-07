defmodule ApiWeb.BackendChannel do
  use ApiWeb, :channel

  alias Data.Context
  alias Data.Schema.User

  def join("backend:" <> user_id, _params, socket) do
    with {:ok, user} <- Data.Schema.User.entity_ok!(user_id),
         true <- socket.assigns.current_user.id == user.id do
      {:ok, socket}
    else
      nil -> {:error, %{message: "Incorrect User Id"}}
      _ -> {:error, %{message: "Not able to Join Channel"}}
    end
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
  