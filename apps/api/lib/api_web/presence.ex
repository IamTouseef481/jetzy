defmodule ApiWeb.Presence do
  use Phoenix.Presence,
      otp_app: :api_web,
      pubsub_server: Api.PubSub

  def get_active_users(topic) do
    Enum.map(list(topic), fn {key, _} ->
      key
    end)
  end
end