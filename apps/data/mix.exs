defmodule Data.MixProject do
  use Mix.Project

  def project do
    [
      app: :data,
      version: "0.1.43",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: (Mix.env() == :prod || Mix.env() == :stage),
      aliases: aliases(),
      deps: deps(),
      xref: [exclude: [Api.Guardian, NimbleCSV, ApiWeb.Utils.Common]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :phoenix_ecto, :google_maps],
      mod: {Data.Application, [:ex_aws]}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:vnext), do: ["lib", "wip_lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.6.2"},
      {:elixir_uuid, "~> 1.2", override: true},
      {:ecto, "~> 3.7.2", override: true},
      {:ecto_sql, "~> 3.7.2", override: true},
      {:postgrex, ">= 0.0.0"},
      {:ecto_psql_extras, "~> 0.7"},
      {:comeonin, "~> 5.2"},
      {:inflex, "~> 2.1"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:sweet_xml, "~> 0.7.1"},
      {:phoenix_ecto, "~> 4.0", override: true},
      {:guardian, "~> 2.0"},

      # Telemetry
      {:phoenix_live_dashboard, "~> 0.6"},
      {:parse_trans, "~> 3.4.1", override: true},
      {:telemetry_metrics, "~> 0.6", override: true},
      {:telemetry_poller, "~> 0.5", override: true},
      {:cowboy_telemetry, "~> 0.4", override: true},
      {:telemetry, "~> 1.0", override: true},
      {:elixometer, "~> 1.5", override: true},
      {:new_relic_agent, "~> 1.0"},

      # JSON/REST
      {:poison, "~> 3.1.0", override: true},
      {:html_sanitize_ex, "~> 1.4"},

      # Test
      {:mock, "~> 0.3.1", optional: true},

      # Image Processing
      {:mogrify, "~> 0.9.1"},
      {:blurhash, "~> 1.0.0"},


      # Discord  https://blog.discordapp.com/scaling-elixir-f9b8e1e7c29b
      {:fastglobal, "~> 1.0"}, # https://github.com/discordapp/fastglobal
      {:semaphore, "~> 1.0"}, # https://github.com/discordapp/semaphore


      # Crypto
      {:pbkdf2_elixir, "~> 1.0"},
      {:bcrypt_elixir, "~> 2.0"},

      # Cors
      {:cors_plug, "~> 2.0"},

      {:markdown, github: "devinus/markdown"},
      {:codepagex, "~> 0.1"},

      # Noizu Forks
      {:amnesia, git: "https://github.com/noizu/amnesia.git", tag: "0.2.8", override: true}, # Mnesia Wrapper Fork
      {:exquisite, git: "https://github.com/noizu/exquisite.git", ref: "61d48f8", override: true},
      {:sendgrid, github: "noizu/sendgrid_elixir", ref: "52d6d17", override: true}, # Derived from Sendgrid Api Wrapper (https://github.com/alexgaribay/sendgrid_elixir)
      {:distillery, git: "https://github.com/noizu/distillery.git", ref: "6700edb", override: true},


      # Noizu Libraries
      {:noizu_core, github: "noizu/ElixirCore", tag: "1.0.17", override: true},
      {:noizu_advanced_pool, git: "https://github.com/noizu-labs/SimplePoolAdvanced.git", branch: "master", override: true},
      {:noizu_advanced_scaffolding, git: "https://github.com/noizu-labs/ElixirScaffoldingAdvanced.git", tag: "1.2.12", override: true},
      {:noizu_kitchen_sink_advanced, git: "https://github.com/noizu-labs/KitchenSinkAdvanced.git", tag: "0.3.9", override: true},
      {:noizu_mnesia_versioning, github: "noizu/MnesiaVersioning", tag: "0.1.9", override: true},
      {:noizu_rule_engine, github: "noizu/RuleEngine", tag: "0.2.0"},

      # Time
      {:tzdata, "~> 1.1", override: true},
      {:timex, "~> 3.7", override: true},
      {:hackney, "~> 1.0"},

      # DB
      {:redix, ">= 0.0.0", override: true},
      {:decimal, "~> 1.9.0", override: true},
      {:db_connection, "~> 2.4.0", override: true},
      {:mssqlex_v3, "~> 3.0.0"},
      {:mssql_ecto, github: "whossname/mssql_ecto", ref: "f11560f763ea6aff998b119ed4f47d25a00746ae"},

      # Stripe
      {:stripity_stripe, "~> 2.0"},
    
      # Search
      {:giza_sphinxsearch, "~> 1.0"},
      {:xml_builder, "~> 2.1.1"},

      # Cron Task Support
      {:quantum, "~> 2.2"}, # Cron like scheduling support





      {:google_maps, "~> 0.11"},


      {:geo, "~> 3.4"},
      {:geo_postgis, "~> 3.4"},
      {:csv, "~> 2.4.1"},
      {:securex, "~> 1.0.5"},
      {:scrivener_ecto, "~> 2.7"},
      {:tds, ">= 0.0.0"},
      {:credo, "~> 1.6", only: :dev},

      # DB
      {:decimal, "~> 1.9.0", override: true},
      {:db_connection, "~> 2.4.0", override: true},
      {:sext, "~> 1.8.0", optional: true},
      {:mnesia_rocksdb, github: "aeternity/mnesia_rocksdb", ref: "ab15b7f3990", override: true},
      {:rocksdb, git: "https://gitlab.com/seanhinde/erlang-rocksdb.git", ref: "9ae37839", override: true},
  
      # Code Cleanup
      {:ex_fixer, github: "noizu/ex_fixer", branch: "master", only: [:dev, :test]},
  
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run apps/data/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
#TODO
      #      "iex -S mix phx.server": "compile --warnings-as-errors",
#      "iex -S mix phx.server": "credo --all",


      test: ["test"]
    ]
  end

end
