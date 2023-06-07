defmodule ApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api


  @session_options [
    store: :cookie,
    key: "_jetzy_key",
    signing_salt: "xtVB70j/"
  ]


  socket "/socket", ApiWeb.UserSocket,
   websocket: true,
   longpoll: false

  socket "/live",
         Phoenix.LiveView.Socket,
         websocket: [
           connect_info: [
             session: @session_options
           ]
         ]

  # Control when to keep raw copy of body for hmac validation.

  def embed_raw_body(%Plug.Conn{path_info: ["stripe", "event-handler"]}), do: true
  def embed_raw_body(_), do: false


  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :api,
    gzip: false,
    only: ~w(assets img css fonts images movie Splash select-resources js favicon.ico robots.txt webm Content Select apple-app-site-association)


  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
       param_key: "aladflk2039fj",
       cookie_key: "a493jfsd"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, ApiWeb.Parsers.Json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    copy_body: &ApiWeb.Endpoint.embed_raw_body/1

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_api_key",
    signing_salt: "7deNAzuh"

  plug CORSPlug
  plug Api.Plugs.GenerateSwagger
  plug ApiWeb.Router
end
