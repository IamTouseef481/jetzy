defmodule Api.MixProject do
  use Mix.Project

  def project do
    [
      app: :api,
      version: "0.1.43",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ compilers(Mix.env()),
      start_permanent: (Mix.env() == :prod || Mix.env() == :stage),
      aliases: aliases(),
      deps: deps(),
      xref: [exclude: Api.Guardian],
      xref: [exclude: ApiWeb.Utils.Common]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Api.Application, []},
      extra_applications: [:logger, :runtime_tools, :data, :os_mon, :mnesia, :crypto, :ssl]
    ]
  end

  defp compilers(:dev), do: [:phoenix_swagger]
  defp compilers(_), do: []

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  def deps do
    [
      [
        {:data, in_umbrella: true},
        # {:secure_x, in_umbrella: true},
      # Phoenix
        {:phoenix, "~> 1.6.2"},
        {:phoenix_pubsub, "~> 2.0"},

      # Telemetry
      {:phoenix_live_dashboard, "~> 0.6"},
      {:parse_trans, "~> 3.4.1", override: true},
        {:telemetry_metrics, "~> 0.6", override: true},
        {:telemetry_poller, "~> 0.5", override: true},
        {:cowboy_telemetry, "~> 0.4", override: true},
        {:telemetry, "~> 1.0", override: true},
        {:elixometer, "~> 1.5", override: true},

      # JSON/REST
      {:poison, "~> 3.1.0", override: true},

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

      # Noizu Forks
        {:amnesia, git: "https://github.com/noizu/amnesia.git", tag: "0.2.8", override: true}, # Mnesia Wrapper Fork
        {:exquisite, git: "https://github.com/noizu/exquisite.git", ref: "61d48f8", override: true},
        {:sendgrid, github: "noizu/sendgrid_elixir", ref: "52d6d17", override: true}, # Derived from Sendgrid Api Wrapper (https://github.com/alexgaribay/sendgrid_elixir)


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


      # DB
      {:redix, ">= 0.0.0", override: true},
      {:decimal, "~> 1.9.0", override: true},
      {:db_connection, "~> 2.4.0", override: true},
      {:mssqlex_v3, "~> 3.0.0"},
      {:mssql_ecto, github: "whossname/mssql_ecto", ref: "f11560f763ea6aff998b119ed4f47d25a00746ae"},

      # Search
      {:giza_sphinxsearch, "~> 1.0"},
      {:xml_builder, "~> 2.1.1"},

      # Cron Task Support
      {:quantum, "~> 2.2"}, # Cron like scheduling support

      # Machine Learning
        {:ex_aws_rekognition, "~> 0.6.0"},
        
      # Monitoring
        {:new_relic_agent, "~> 1.0"},
      
      # SASS
        {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
        {:dart_sass, "~> 0.2", runtime: Mix.env() == :dev},

      # Misc
        {:gettext, "~> 0.11"},
        {:plug, "~> 1.13.6", override: true},
        {:plug_cowboy, "~> 2.0"},
        {:casex, "~> 0.4.1"},
        {:filterable, "~> 0.7.4"},
        {:phoenix_swagger, "~> 0.8.3"},
        {:ex_json_schema, "~> 0.5"},
        # OpenID Connect - Apple and Google OAuth
        {:openid_connect, "~> 0.2.2"},
        {:facebook_updated, "~> 0.24.2"},
        {:ex_aws, "~> 2.0"},
        {:ex_aws_s3, "~> 2.0"},
      #{:sendgrid, "~> 2.0"},
        {:oban, "~> 2.10"},
        {:nimble_csv, "~> 1.1"},
        {:fcmex, "~> 0.5.0"},
        {:mogrify, "~> 0.9.1"}
      ],
      [
        {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
        {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
      ]
    ]
    |> Enum.concat()
  end
  
  defp aliases() do
   [
     "assets.deploy": [
       "esbuild default --minify",
       "sass default --no-source-map --style=compressed",
       "phx.digest"
     ]
   ]
  end
end
