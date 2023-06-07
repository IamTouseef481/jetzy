defmodule Api.Plugs.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :Api,
    module: Api.Guardian,
    error_handler: Api.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
