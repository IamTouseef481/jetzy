import Config

get_env = fn var, env, required ->
  cond do
    v = System.get_env(var) ->
      v

    required == true || required == :required ->
      raise(
        "#{env.file}:#{env.line}  Config Error - User must set #{var}=[...] environment variable"
      )

    required == :silent ->
      nil

    :else ->
      IO.puts(
        "#{env.file}:#{env.line} Config Error - User should set #{var}=[...] environment variable"
      )

      nil
  end
end

config :stripity_stripe,
  api_key: get_env.("JETZY_PREPROD_STRIPE_API_KEY", __ENV__, :required)

# Do no include JetzySchema.MSSQL.Repo we must not rebuild/drop it during migration operations.
config :data, ecto_repos: [JetzySchema.PG.Repo, Data.Repo], root_dir: "/mnt"

config :data, JetzySchema.MSSQL.Repo,
  pool_size: 50,
  log: :debug,
  username: get_env.("JETZY_PREPROD_MSSQL_USER", __ENV__, :required),
  password: get_env.("JETZY_PREPROD_MSSQL_PASSWORD", __ENV__, :required),
  database: get_env.("JETZY_PREPROD_MSSQL_DATABASE", __ENV__, :required),
  hostname: get_env.("JETZY_PREPROD_MSSQL_HOST", __ENV__, :required),
  port: 1433,
  timeout: 1_000_000,
  show_sensitive_data_on_connection_error: false

config :data, JetzySchema.PG.Repo,
  username: get_env.("JETZY_PREPROD_DB_USER_NAME", __ENV__, :required),
  password: get_env.("JETZY_PREPROD_DB_PASSWORD", __ENV__, :required),
  database: get_env.("JETZY_PREPROD_DB_NAME", __ENV__, :required),
  hostname: get_env.("JETZY_PREPROD_DB_HOST_NAME", __ENV__, :required),
  instance_name: "JetzyDb",
  port: 5432,
  pool_size: 50,
  trust_server_certificate: true,
  encrypt: false,
  show_sensitive_data_on_connection_error: false,
  log: :debug

config :data, Data.Repo,
  types: Data.PostgresTypes,
  username: get_env.("JETZY_PREPROD_DB_USER_NAME", __ENV__, :required),
  password: get_env.("JETZY_PREPROD_DB_PASSWORD", __ENV__, :required),
  database: get_env.("JETZY_PREPROD_DB_NAME", __ENV__, :required),
  hostname: get_env.("JETZY_PREPROD_DB_HOST_NAME", __ENV__, :required),
  migration_primary_key: [id: Ecto.UUID, type: :uuid],
  migration_timestamps: [type: :utc_datetime],
  port: 5432,
  pool_size: 250,
  trust_server_certificate: true,
  encrypt: false,
  show_sensitive_data_on_connection_error: false,
  log: :debug

config :data, :legacy,
  legacy_vi_key: get_env.("JETZY_PREPROD_LEGACY_VI_KEY", __ENV__, :required),
  legacy_password_hash: get_env.("JETZY_PREPROD_LEGACY_PASSWORD_HASH", __ENV__, :required),
  legacy_password_salt: get_env.("JETZY_PREPROD_LEGACY_PASSWORD_SALT", __ENV__, :required)

config :logger, level: :warn

# Override Mnesia Folder (For Dev Sandbox)
mnesia_dir =
  ((m = get_env.("JETZY_PREPROD_OVERRIDE_MNESIA_DIR", __ENV__, :silent)) && String.to_charlist(m)) ||
    String.to_charlist("//mnt/mnesia/jetzy-preprod/")

config :mnesia,
  dir: mnesia_dir

config :google_maps,
  api_key: get_env.("JETZY_PREPROD_GOOGLE_API_KEY", __ENV__, :optional)

config :noizu_mnesia_versioning,
  topology_provider: JetzySchema.Mnesia.TopologyProvider,
  schema_provider: JetzySchema.Mnesia.SchemaProvider,
  mnesia_migrate_on_start: false

config :data, :legacy,
  legacy_vi_key: get_env.("JETZY_PREPROD_LEGACY_VI_KEY", __ENV__, :required),
  legacy_password_hash: get_env.("JETZY_PREPROD_LEGACY_PASSWORD_HASH", __ENV__, :required),
  legacy_password_salt: get_env.("JETZY_PREPROD_LEGACY_PASSWORD_SALT", __ENV__, :required)

config :data, :aws,
  storage_bucket: get_env.("JETZY_PREPROD_AWS_STORAGE_BUCKET_NAME", __ENV__, :required),
  base_url: get_env.("JETZY_PREPROD_IMAGE_BASE_URL", __ENV__, :required)

config :data, :search_configuration,
  is_local_radius:
    String.to_integer(get_env.("JETZY_PREPROD_IS_LOCAL_RADIUS", __ENV__, :optional) || "50")

config :pbkdf2_elixir, :rounds, 1

config :data, :sendgrid,
  website: "https://preprod.jetzy.com",
  select_website: "https://preprod-select.jetzy.com",
  cdn: "https://preprod.jetzy.com",
  sendgrid_from_email: get_env.("JETZY_PREPROD_SENDGRID_FROM_EMAIL", __ENV__, :required),
  sendgrid_from_email_name:
    get_env.("JETZY_PREPROD_SENDGRID_FROM_EMAIL_NAME", __ENV__, :required),
  sendgrid_admin_email: get_env.("JETZY_PREPROD_ADMIN_EMAIL", __ENV__, :required),
  email_verification_url: get_env.("JETZY_PREPROD_EMAIL_VERIFICATION_URL", __ENV__, :required)

new_relic_name = get_env.("JETZY_PREPROD_NEW_RELIC_NAME", __ENV__, :optional) || "JetzyElixir"
new_relic_license = get_env.("JETZY_PREPROD_NEW_RELIC_LICENSE", __ENV__, :optional)

config :new_relic_agent,
  app_name: new_relic_name,
  logs_in_context: :direct,
  license_key: new_relic_license

config :data, :firebase,
  api_key: get_env.("JETZY_PREPROD_FIREBASE_WEB_API_KEY", __ENV__, :required)

import_config "preprod.secret.exs"
import_config "../cron_jobs.exs"
