defmodule Data.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Data.Repo,
      #Data.SQL.Repo,
      JetzySchema.PG.Repo,
      #JetzySchema.MSSQL.Repo,
      JetzySchema.Redis,
      Jetzy.Support.Cron
      # Starts a worker by calling: Data.Worker.start_link(arg)
      # {Data.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Data.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
