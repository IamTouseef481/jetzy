defmodule Api.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      ApiWeb.Endpoint,
      {Phoenix.PubSub, [name: Api.PubSub, adapter: Phoenix.PubSub.PG2]},
      ApiWeb.Presence,

      # Telemetry
      JetzyWeb.Telemetry,
  
      con_cache_child_spec(ConCache.Default, [ttl_check_interval: :timer.seconds(30), global_ttl: :timer.seconds(600)]),
      con_cache_child_spec(ConCache.Resident, [ttl_check_interval: :timer.seconds(600), global_ttl: :timer.seconds(60*60*24*2)]),
    
      # Oban Job Processing
      {Oban, oban_config()},

      # Starts a worker by calling: Api.Worker.start_link(arg)
      # {Api.Worker, arg},
      # OpenID for SocialAuth with Google and Apple.
      {OpenIDConnect.Worker, Application.get_env(:api, :openid_connect_providers)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Api.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp con_cache_child_spec(name, settings) do
    settings = put_in(settings, [:name], name)
    Supervisor.child_spec(
      {
        ConCache,
        settings
      },
      id: {ConCache, name}
    )
  end
  

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.fetch_env!(:api, Oban)
  end
end
