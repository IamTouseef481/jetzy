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


config :stripity_stripe,
       api_key: System.get_env("JETZY_TEST_STRIPE_API_KEY")


config :data, Data.Repo,
  types: Data.PostgresTypes, 
  username: "postgres",
  password: "postgres",
  database: "jetzy_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [id: Ecto.UUID, type: :uuid],
  migration_timestamps: [type: :utc_datetime]

# Print only warnings and errors during test
config :logger, level: :warn


config :api, JetzySchema.MSSQL.Repo,
       pool: Ecto.Adapters.SQL.Sandbox

config :api, JetzySchema.PG.Repo,
       pool: Ecto.Adapters.SQL.Sandbox
