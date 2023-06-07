defmodule Api.Plugs.AdminAuth do
    import Plug.Conn
    alias Data.Context.Users

    def init(opts), do: opts

    def call(conn, _opts) do
      %{id: user_id} = Guardian.Plug.current_resource(conn)

      case Users.get_user_role(user_id) do
        "admin" -> conn
        _ ->
           conn
           |> put_resp_content_type("application/json")
           |> send_resp(403, Poison.encode!(%{errors: "Permission Denied"}))
           |> Plug.Conn.halt()
      end

      end
  end
