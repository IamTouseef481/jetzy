defmodule Jetzy.SocialClients.Client do
  alias Jetzy.SocialClients

  def user_info(:apple,    token), do: SocialClients.Apple.user_info(token)
  def user_info(:facebook, token), do: SocialClients.Facebook.user_info(token)
  def user_info(:google,   token), do: SocialClients.Google.user_info(token)
end
