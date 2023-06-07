defmodule Api.Plugs.Authorize do
  @behaviour Plug

  import Plug.Conn
  alias Api.Guardian
  def init(default), do: default

  def call(conn, _) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims),
         {:ok, %Plug.Conn{}} <- check_permissions(conn, user) do
      conn
    else
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Poison.encode!(%{errors: error}))
        |> Plug.Conn.halt()

      _r ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Poison.encode!(%{errors: ["Permission Denied"]}))
        |> Plug.Conn.halt()
    end
  end


  @doc """
    Bypassing resources here where single verb role access is not sufficiently granular.
    Existing logic is not always appropriate for nested resource access, etc. where user must have permission to both the parent and nested element.
    Or where both must be considered in the permission check.
  """
  defp custom_auth_logic(%{method: method, path_info: path_info} = conn) do
    case path_info do
      ["api", "v1.0", "select", _, "concierge", request] when request in ["booking", "question", "request"] -> true
      ["api", "v1.0", "active-user", "status"] -> true
      ["api", "v1.0", "active-user", "account"] -> true
      ["api", "v1.0", "admin", "users", "status"] -> true
      ["api", "v1.0", "admin", "select", "sign-ups"] -> true
      ["api", "v1.0", "admin", "select", "sign-ups", _, "approve"] -> true
      ["api", "v1.0", "admin", "user", _, "select", "subscriptions", "grant"] -> true
      _ -> false
    end
  end
  

  defp check_permissions(%{method: method, path_info: path_info} = conn, %{id: user_id}) do
    IO.inspect path_info
    res = Enum.at(path_info, -1) # should is not appropriate for restful best practices.  nested routes.
    res =
      case Ecto.UUID.dump(res) do
        {:ok, _info} -> Enum.at(path_info, -2)
        _ -> if res in Data.Context.list_ids(Data.Schema.Role), do: Enum.at(path_info, -2), else: res
      end
    cond do
      user_id && custom_auth_logic(conn) ->
        context = Noizu.ElixirCore.CallingContext.system(conn, %{}) # Todo restrict permissions
                  |> put_in([Access.key(:caller)], {:ref, Data.User, user_id})
        conn = Plug.Conn.put_private(conn, :context, context)
        {:ok, conn}
      SecureX.has_access?(user_id, res, method) ->
        context = Noizu.ElixirCore.CallingContext.system(conn, %{}) # Todo restrict permissions
                  |> put_in([Access.key(:caller)], {:ref, Data.User, user_id})
        conn = Plug.Conn.put_private(conn, :context, context)
        {:ok, conn}
      false -> {:error, false}
    end
  end

  defp check_permissions(_, _), do: {:error, ["Invalid Request"]}
end
