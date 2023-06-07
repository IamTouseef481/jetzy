defmodule JetzyWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [

      # Custom
      counter("api_web.request.error.count"),
      counter("analytics.user.registration.count"),
      counter("analytics.user.registration_complete.count"),
      counter("analytics.user.follow.count"),
      counter("analytics.user.unfollow.count"),
      counter("analytics.post.created.count"),
      counter("analytics.post.favorite.count"),
      counter("analytics.comment.created.count"),
      counter("analytics.comment.favorite.count"),


      # Phoenix Metrics
      summary(
        "phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary(
        "phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("data.repo.query.total_time", unit: {:native, :millisecond}),
      summary("data.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("data.repo.query.query_time", unit: {:native, :millisecond}),
      summary("data.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("data.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {JetzyWeb, :count_users, []}
    ]
  end
end
