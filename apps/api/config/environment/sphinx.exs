import Config


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

default_hard_limit = 250_000
default_soft_limit = 150_000
default_target = 75_000

{type, environment, include_env, port, mnesia_dir} = cond do
   true ->
     mnesia_dir = (m = get_env.("JETZY_SPHINX_OVERRIDE_MNESIA_DIR", __ENV__, :silent)) && String.to_charlist(m) || String.to_charlist("//mnt/mnesia/jetzy-sphinx/")
     {:prod, :prod, :prod, 81, mnesia_dir}
end


config :api, :otp_settings,
       critical_schema: [
         #Noizu.SimplePool.V3.Database.MonitoringFramework.ServerEventTable,
         #Noizu.SimplePool.V3.Database.MonitoringFramework.ServiceEventTable,
         #Noizu.SimplePool.V3.Database.MonitoringFramework.DetailedServiceEventTable,
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
       default_components: [],
       master_node: false,
       start_endpoint: false,
       start_scheduler: false,
       script_mode: true


# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :api, JetzyWeb.Endpoint,
       http: [:inet6, port: port],
       url: [host: "localhost", port: port],
       cache_static_manifest: "priv/static/cache_manifest.json",
       server: true,
       root: ".",
       check_origin: ["//localhost:4200", "//localhost", "//127.0.0.1",  "//*.jetzyapp.com","//crisis-help.com", "//crisis-covid.com", "//ios.client.jetzyapp.com", "//android.client.jetzyapp.com"],
       version: Application.spec(:phoenix_distillery, :vsn)

# Do not print debug messages in production
config :logger, level: :error

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :api, JetzyWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: get_env.("SOME_APP_SSL_KEY_PATH", __ENV__, :required),
#         certfile: get_env.("SOME_APP_SSL_CERT_PATH", __ENV__, :required)
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :api, JetzyWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# Finally import the config/prod.secret.exs which loads secrets
# and configuration from environment variables.

#-------------------------------------------------------------------------------
# Mnesia & MnesiaVersioning
#-------------------------------------------------------------------------------
config :noizu_mnesia_versioning,
       environment: :prod

# Override Mnesia Folder (For Dev Sandbox)
config :mnesia,
       dir: mnesia_dir

import_config "sphinx.secret.exs"
