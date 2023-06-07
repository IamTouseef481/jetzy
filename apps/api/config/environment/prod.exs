import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.


IO.puts """
---------------------------------------------
  PROD CONFIGURATION
---------------------------------------------
"""



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

protocol_options = [
  request_timeout: 100_000_000,
  shutdown_timeout: 100_000_000,
  idle_timeout: 100_000_000,
  linger_timeout: 100_000_000,
]

config :api, :cdn,
       path: "/mnt/images/jetzy",
       upload: "/mnt/upload"

config :api, :stripe,
       webhook_secret: get_env.("JETZY_PROD_STRIPE_WEBHOOK_SECRET", __ENV__, :required)
       
config :api, :schema,
       mssql_username: get_env.("JETZY_PROD_MSSQL_USER", __ENV__, :required),
       mssql_password: get_env.("JETZY_PROD_MSSQL_PASSWORD", __ENV__, :required),
       mssql_database: get_env.("JETZY_PROD_MSSQL_DATABASE", __ENV__, :required),
       mssql_hostname: get_env.("JETZY_PROD_MSSQL_HOST", __ENV__, :required),
       pg_db_user: get_env.("JETZY_PROD_DB_USER_NAME", __ENV__, :required),
       pg_db_password: get_env.("JETZY_PROD_DB_PASSWORD", __ENV__, :required),
       pg_db_name: get_env.("JETZY_PROD_DB_NAME", __ENV__, :required),
       pg_db_host: get_env.("JETZY_PROD_DB_HOST_NAME", __ENV__, :required),
       pg_db_pool: get_env.("JETZY_PROD_DB_POOL_SIZE", __ENV__, :required),
       pg_db_odbc: get_env.("JETZY_PROD_DB_URL", __ENV__, :required),
       pg_db_port: get_env.("JETZY_PROD_DB_PORT", __ENV__, :required)

#-------------------------------------------------------------------------------
# fcmex (SMS) config
#-------------------------------------------------------------------------------
fcm_server_key = get_env.("JETZY_PROD_FCM_SERVER_KEY", __ENV__, :required)
fcm_sender_id = get_env.("JETZY_PROD_FCM_SENDER_ID", __ENV__, :required)

config :fcmex,
       server_key: fcm_server_key,
       sender_id: fcm_sender_id

#-------------------------------------------------------------------------------
# SocialAuth with OpenID
#-------------------------------------------------------------------------------
google_app_id = get_env.("JETZY_PROD_GOOGLE_APP_ID", __ENV__, :optional)
google_app_secret = get_env.("JETZY_PROD_GOOGLE_APP_SECRET", __ENV__, :optional)

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
guardian_secret = get_env.("JETZY_PROD_GUARDIAN_SECRET", __ENV__, :required)
config :api, Api.Guardian,
       issuer: "jetzy",
       secret_key: guardian_secret

#-------------------------------------------------------------------------------
#AWS S3 config
#-------------------------------------------------------------------------------
config :ex_aws,
       access_key_id: get_env.("JETZY_PROD_AWS_ACCESS_KEY_ID", __ENV__, :required),
       secret_access_key: get_env.("JETZY_PROD_AWS_SECRET_ACCESS_KEY", __ENV__, :required),
       region: get_env.("JETZY_PROD_AWS_REGION", __ENV__, :required)

#-------------------------------------------------------------------------------
#SendGrid config
#-------------------------------------------------------------------------------
sendgrid_api_key = get_env.("JETZY_PROD_SENDGRID_API_KEY", __ENV__, :required)
config :sendgrid,
       api_key: sendgrid_api_key



#-------------------------------------------------------------------------------
# Configures the endpoint
#-------------------------------------------------------------------------------


host = get_env.("JETZY_PROD_API_HOST_URL", __ENV__, :required)
secret_key_base = get_env.("JETZY_PROD_API_SECRET_KEY_BASE", __ENV__, :required)
live_view_signing_salt = get_env.("JETZY_PROD_LIVE_VIEW_SIGNING_SALT", __ENV__, :required)
port = get_env.("JETZY_PROD_API_PORT", __ENV__, :required)
new_relic_name = get_env.("JETZY_PROD_NEW_RELIC_NAME", __ENV__, :required)
new_relic_license = get_env.("JETZY_PROD_NEW_RELIC_LICENSE", __ENV__, :required)

environment = Mix.env

config :api, ApiWeb.Endpoint,
       url: [host: host],
       http: [port: port, protocol_options: protocol_options],
       debug_errors: false,
       code_reloader: false,
       check_origin: false,
       server: true,
       root: ".",
       environment: :prod,
       secret_key_base: secret_key_base,
       render_errors: [view: ApiWeb.ErrorView, accepts: ~w(json)],
       pubsub_server: Api.PubSub,
       live_view: [
         signing_salt: live_view_signing_salt
       ],
       cache_static_manifest: "priv/static/cache_manifest.json",
       watchers: []

config :api, :configuration,
       referral_code_url: get_env.("JETZY_PROD_REFERRAL_CODE_URL", __ENV__, :optional)
       
config :api, :firebase,
       api_key: get_env.("JETZY_PROD_FIREBASE_WEB_API_KEY", __ENV__, :required)
       
config :new_relic_agent,
       app_name: new_relic_name,
       logs_in_context: :direct,
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
       log_level: :warn
       
# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 10

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :compile


#-------------------------------------------------------------------------------
# Configures the phoenix swagger
#-------------------------------------------------------------------------------
config :api, :phoenix_swagger,
       swagger_files: %{
         "priv/static/swagger.json" => [
           router: ApiWeb.Router, # phoenix routes will be converted to swagger paths
           url: [host: host, port: 443],
           schemes: ["https"],
         ]
       }


#-------------------------------------------------------------------------------
# Mnesia & MnesiaVersioning
#-------------------------------------------------------------------------------
config :noizu_mnesia_versioning,
       environment: :prod

default_hard_limit = 250_000
default_soft_limit = 150_000
default_target = 75_000


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


import_config "prod.secret.exs"
import_config "../cron/prod_cron.exs"