import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.



get_env = fn(var, env, required) ->
  cond do
    v = System.get_env(var) -> v
    required == true || required == :required -> raise("#{env.file}:#{env.line}  Config Error - User must set #{var}=[...] environment variable")
    required == :silent -> nil
    :else ->
      IO.puts "#{env.file}:#{env.line} Config Error - User should set #{var}=[...] environment variable"
      nil
  end
end

IO.puts """
---------------------------------------------
  DEV CONFIGURATION
---------------------------------------------
"""
protocol_options = [
  request_timeout: 100_000_000,
  shutdown_timeout: 100_000_000,
  idle_timeout: 100_000_000,
  linger_timeout: 100_000_000,
]

# root_dir = get_env.("ROOT_DIR", __ENV__, :optional) || "/mnt"

config :api, :cdn,
  path: "/images/jetzy-dev",
  upload: "/upload"





#-------------------------------------------------------------------------------
# fcmex (SMS) config
#-------------------------------------------------------------------------------
fcm_server_key = get_env.("FCM_SERVER_KEY", __ENV__, :required)
fcm_sender_id = get_env.("FCM_SENDER_ID", __ENV__, :required)

config :fcmex,
       server_key: fcm_server_key,
       sender_id: fcm_sender_id

#-------------------------------------------------------------------------------
# SocialAuth with OpenID
#-------------------------------------------------------------------------------
google_app_id = get_env.("GOOGLE_APP_ID", __ENV__, :optional)
google_app_secret = get_env.("GOOGLE_APP_SECRET", __ENV__, :optional)

config :api, :openid_connect_providers,
       google: [
         discovery_document_uri: "https://accounts.google.com/.well-known/openid-configuration",
         app_id: google_app_id,
         app_secret: google_app_secret
       ],
       apple: [
         discovery_document_uri: "https://appleid.apple.com/.well-known/openid-configuration"
       ]


#-------------------------------------------------------------------------------
#Guardian config for auth
#-------------------------------------------------------------------------------
guardian_secret = get_env.("GUARDIAN_SECRET", __ENV__, :required)
config :api, Api.Guardian,
       issuer: "jetzy",
       secret_key: guardian_secret

#-------------------------------------------------------------------------------
#AWS S3 config
#-------------------------------------------------------------------------------
config :ex_aws,
       access_key_id: get_env.("ACCESS_KEY_ID", __ENV__, :required),
       secret_access_key: get_env.("SECRET_ACCESS_KEY", __ENV__, :required),
       region: get_env.("AWS_REGION", __ENV__, :required)

#-------------------------------------------------------------------------------
#SendGrid config
#-------------------------------------------------------------------------------
sendgrid_api_key = get_env.("SENDGRID_API_KEY", __ENV__, :required)
config :sendgrid,
       api_key: sendgrid_api_key

#-------------------------------------------------------------------------------
# Configures the endpoint
#-------------------------------------------------------------------------------
new_relic_name = get_env.("JETZY_DEV_NEW_RELIC_NAME", __ENV__, :optional) || "JetzyElixirDev"
new_relic_license = get_env.("JETZY_DEV_NEW_RELIC_LICENSE", __ENV__, :optional)


host = get_env.("API_HOST_URL", __ENV__, :required)
port = get_env.("API_PORT", __ENV__, :required)
secret_key_base = get_env.("API_SECRET_KEY_BASE", __ENV__, :required)
live_view_signing_salt = get_env.("LIVE_VIEW_SIGNING_SALT", __ENV__, :required)
{environment, port} = case Mix.env do
                        :prod -> {:prod, 80}
                        :dev -> {:dev, 8080}
                        :sphinx  -> {:sphinx, 81}
                        other -> {other, 9090}
                      end

config :api, ApiWeb.Endpoint,
       url: [host: host],
       secret_key_base: secret_key_base,
       render_errors: [view: ApiWeb.ErrorView, accepts: ~w(json)],
       pubsub_server: Api.PubSub,
       environment: Mix.env,
       live_view: [
         signing_salt: live_view_signing_salt
       ]

config :api, ApiWeb.Endpoint,
  http: [port: port, protocol_options: protocol_options],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {
      Esbuild,
      :install_and_run,
      [:default, ~w(--sourcemap=inline --watch)]
    },
    sass: {
      DartSass,
      :install_and_run,
      [:default, ~w(--embed-source-map --source-map-urls=absolute --watch)]
    }
]

config :api, :configuration,
       referral_code_url: get_env.("REFERRAL_CODE_URL", __ENV__, :optional)

config :api, :firebase,
       api_key: get_env.("FIREBASE_WEB_API_KEY", __ENV__, :required)



config :new_relic_agent,
       app_name: new_relic_name,
       #logs_in_context: :direct,
       license_key: new_relic_license

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :logger,
       truncate: :infinity,
       log_level: :debug


# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 250

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime


#-------------------------------------------------------------------------------
# Mnesia & MnesiaVersioning
#-------------------------------------------------------------------------------
config :noizu_mnesia_versioning,
       environment: :dev

# Override Mnesia Folder (For Dev Sandbox)
mnesia_dir = (m = get_env.("JETZY_DEV_OVERRIDE_MNESIA_DIR", __ENV__, :silent)) && String.to_charlist(m) || String.to_charlist("//mnt/mnesia/jetzy-dev/")
config :mnesia,
       dir: mnesia_dir


default_hard_limit = 250_000
default_soft_limit = 150_000
default_target = 75_000



#-------------------------------------------------------------------------------
# Configures the phoenix swagger
#-------------------------------------------------------------------------------
config :api, :phoenix_swagger,
       swagger_files: %{
         "priv/static/swagger.json" => [
           router: ApiWeb.Router, # phoenix routes will be converted to swagger paths
         ]
       }

config :api, :stripe,
       webhook_secret: get_env.("JETZY_DEV_STRIPE_WEBHOOK_SECRET", __ENV__, :silent)

config :api, :otp_settings,
       critical_schema: [
         Noizu.SimplePool.V3.Database.MonitoringFramework.ServerEventTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.ServiceEventTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.DetailedServiceEventTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.ServiceTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.NodeTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.ConfigurationTable,
         Noizu.SimplePool.V3.Database.MonitoringFramework.SettingTable,
         Noizu.SimplePool.V3.Database.Cluster.Node.TaskTable,
         Noizu.SimplePool.V3.Database.Cluster.Node.WorkerTable,
         Noizu.SimplePool.V3.Database.Cluster.Node.StateTable,
         Noizu.SimplePool.V3.Database.Cluster.Service.Instance.StateTable,
         Noizu.SimplePool.V3.Database.Cluster.Service.TaskTable,
         Noizu.SimplePool.V3.Database.Cluster.Service.WorkerTable,
         Noizu.SimplePool.V3.Database.Cluster.Service.StateTable,
         Noizu.SimplePool.V3.Database.Cluster.TaskTable,
         Noizu.SimplePool.V3.Database.Cluster.StateTable,
         Noizu.SimplePool.V3.Database.Cluster.SettingTable,

       ],
       required_schema: [
       ],
       default_components: [
       ],
       master_node: true,
       start_endpoint: true,
       start_scheduler: false

import_config "../cron/one_box_cron.exs"
