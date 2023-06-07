# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

{environment, port} = case Mix.env do
  :prod -> {:prod, 80}
  :dev -> {:dev, 8080}
  :sphinx  -> {:sphinx, 81}
  other -> {other, 9090}
end

config :api, :tanbits_shim,
       enable_shim: true,
       include_vnext: false

if Mix.env == :vnext do
  config :api, :tanbits_shim,
         enable_shim: true,
         include_vnext: true
end

config :noizu_advanced_scaffolding,
       universal_reference_type: :uuid


config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(
    js/phoenix-bootstrap.ts
    js/page/payment.ts
    js/select.ts
    --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.43.1",
  default: [
    args: ~w(
    css/phoenix-bootstrap.scss:../priv/static/assets/phoenix-bootstrap.css
    css/select.scss:../priv/static/assets/select.css
    css/page/:../priv/static/assets/page/
    css/select/:../priv/static/assets/select/
    ),
    cd: Path.expand("../assets", __DIR__)
  ]


#-------------------------------------------------------------------------------
# Oban config
#-------------------------------------------------------------------------------
config :api, Oban,
  repo: Data.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 10_000}],
  queues: [
    default: 10,
    events: 50,
    media: 20,
    user_activation: 20,
    like_comment: 20
  ]

#-------------------------------------------------------------------------------
# Exometer
#-------------------------------------------------------------------------------
config(:exometer_core, report: [reporters: [{:exometer_report_tty, []}]])
config(:elixometer,
  reporter: :exometer_report_tty,
  update_frequency: 30_000,
  env: Mix.env,
  metric_prefix: "jetzy")


#-------------------------------------------------------------------------------
# Use Poison for JSON parsing in Phoenix
#-------------------------------------------------------------------------------
config :phoenix, :json_library, Poison
config :phoenix_swagger, json_library: Poison


#-------------------------------------------------------------------------------
# Convert API body and response payloads to snake_case and camelCase respectively
#-------------------------------------------------------------------------------
config :phoenix, :format_encoders, json: ApiWeb.Utils.ResponseDataWrapper

#-------------------------------------------------------------------------------
# Configures Elixir's Logger
#-------------------------------------------------------------------------------
config :logger, :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]

#-------------------------------------------------------------------------------
# cors
#-------------------------------------------------------------------------------
config :cors_plug,
       origin: ["*"],
       max_age: 86400,
       methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTION"]

#-------------------------------------------------------------------------------
# mon
#-------------------------------------------------------------------------------
config :os_mon,
       start_cpu_sup: true,
       start_diskup: true,
       start_memsup: true,
       start_os_sup: true

#-------------------------------------------------------------------------------
# CDN
#-------------------------------------------------------------------------------




# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "environment/#{environment}.exs"
