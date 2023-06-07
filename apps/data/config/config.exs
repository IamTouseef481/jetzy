import Config

config :data, ecto_repos: [Data.Repo]

config :ecto_sql, :migration_module, Data.Migration

# Configures the securex
config :securex,
       repo: Data.Repo,
       schema: Data.Schema.User,
       type: :binary_id

config :data, :tanbits_shim,
   enable_shim: true,
   include_vnext: false

if Mix.env == :vnext do
  config :data, :tanbits_shim,
         enable_shim: true,
         include_vnext: true
end

#-------------------------------------------------------------------------------
# Noizu Scaffolding Settings
#-------------------------------------------------------------------------------
import_config "config_noizu.exs"

#-------------------------------------------------------------------------------
# mon
#-------------------------------------------------------------------------------
config :os_mon,
       start_cpu_sup: true,
       start_diskup: false,
       start_memsup: true,
       start_os_sup: false

#-------------------------------------------------------------------------------
# Giza Sphinx Search
#-------------------------------------------------------------------------------
config :giza_sphinxsearch,
       host: 'localhost',
       sql_port: 9307,
       port: 9312,
       http_port: 9308
       
import_config "environment/#{Mix.env()}.exs"