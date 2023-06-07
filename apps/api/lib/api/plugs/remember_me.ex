defmodule Api.Plugs.RememberMe do
  import Plug.Conn
  import Guardian.Plug
  
  def init(opts \\ []), do: opts
  def call(conn, opts) do
    with nil <- Api.Guardian.Plug.current_token(conn, opts),
         {:ok, jwt} <- Guardian.Plug.find_token_from_cookies(conn, opts),
         {:ok, claims} <- Api.Guardian.decode_and_verify(jwt, %{}, opts) do
      conn
      |> Api.Guardian.Plug.put_current_token(jwt, opts)
      |> Api.Guardian.Plug.put_current_claims(claims, opts)
    else
      _ ->
        conn
    end
  end
end