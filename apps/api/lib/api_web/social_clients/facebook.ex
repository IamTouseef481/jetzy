defmodule Jetzy.SocialClients.Facebook do
  def user_info(token) do
    case Facebook.me("email,name,picture.width(720).height(720)", token) do
      {:ok, response} ->
        {:ok, %{
          id: response["id"],
          email: email(response),
          name: name(response),
          picture: picture(response)
        }}
      {:error, _} ->
        {:error, :invalid_token}
    end
  end

  defp email(%{"email" => email}), do: email
  defp email(_), do: nil

  defp name(%{"name" => name}), do: name
  defp name(_), do: nil

  defp picture(%{"picture" => %{"data" => %{"url" => url }}}), do: url
  defp picture(_), do: nil

end
