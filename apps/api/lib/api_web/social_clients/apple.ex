defmodule Jetzy.SocialClients.Apple do
  def user_info(token) do
    case OpenIDConnect.verify(:apple, token) do
      {:ok, claims} ->
        {:ok, %{id: claims["sub"], email: email(claims)}}

      {:error, :verify, _} ->
        {:error, :invalid_token}
    end
  end

  defp email(%{"email_verified" => "false"}), do: nil
  defp email(%{"email_verified" => false}), do: nil
  defp email(%{"is_private_email" => "true"}), do: nil
  defp email(%{"is_private_email" => true}), do: nil
  defp email(%{"email" => email}), do: email
  defp email(_), do: nil
end
