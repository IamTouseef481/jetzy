defmodule ApiWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", ApiWeb.RoomChannel
  channel "event_comments:*", ApiWeb.EventCommentChannel
  channel "chats:*", ApiWeb.UserChatChannel
  channel "interest_topic_chats:*", ApiWeb.InterestTopicChatChannel
  
  # backend for syncing records for active user
  channel "backend:*", ApiWeb.BackendChannel
  
  #  channel to keep live updation on chats listing screen e.g add new chat, any new incoming message
  channel "user:*", ApiWeb.UserChannel
  channel "notification:*", ApiWeb.NotificationChannel
  channel "user_profile:*", ApiWeb.UserProfileChannel
  channel "jetzy_timeline", ApiWeb.JetzyTimelineChannel
  # channel "chats:*", StakesterWeb.NotificationChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, claims} <- Api.Guardian.decode_and_verify(token),
         {:ok, user} <- Api.Guardian.resource_from_claims(claims) do
      socket = assign(socket, :current_user, user)
      {:ok, socket}
    else
      _reason -> :error
    end
  end

  def connect(_params, _socket, _conn_info), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
