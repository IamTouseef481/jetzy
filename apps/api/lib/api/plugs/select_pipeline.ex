defmodule Api.SelectAuthErrorHandler do
  import Plug.Conn
  
  def auth_error(conn, {type, _reason}, _opts) do
    conn
  end
end

defmodule Api.Plugs.Guardian.SelectPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :Api,
    module: Api.Guardian,
    error_handler: Api.SelectAuthErrorHandler

  plug(Api.Plugs.RememberMe)
  plug(Guardian.Plug.LoadResource, halt: false)
end
