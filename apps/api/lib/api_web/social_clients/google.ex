defmodule Jetzy.SocialClients.Google do
  def user_info(token) do
    case OpenIDConnect.verify(:google, token) do
      {:ok, claims} ->
        {:ok, %{
          id: claims["sub"],
          email: email(claims),
          name: name(claims),
          picture: picture(claims)
        }}

      {:error, :verify, _} ->
        {:error, :invalid_token}
    end
  end

  defp email(%{"email_verified" => "false"}), do: nil
  defp email(%{"email_verified" => false}), do: nil
  defp email(%{"email" => email}), do: email
  defp email(_), do: nil

  defp name(%{"name" => name}), do: name
  defp name(_), do: nil

  defp picture(%{"picture" => picture}), do: picture
  defp picture(_), do: nil
end