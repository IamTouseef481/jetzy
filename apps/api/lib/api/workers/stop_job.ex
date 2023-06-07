defmodule Api.Workers.StopJob do
  use Oban.Worker, queue: :user_activation, max_attempts: 1
  import Ecto.Query, warn: false

  def stop_oban_job(worker_name) do
    Oban.Job
    |> Ecto.Query.where(worker: ^worker_name)
    |> Oban.cancel_all_jobs()
  end

  def perform(%Oban.Job{}), do: :ok

end
