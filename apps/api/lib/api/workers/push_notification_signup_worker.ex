defmodule Api.Workers.PushNotificationSignupWorker do
  alias Api.Workers.PushNotificationSignupWorker
  use Oban.Worker, queue: :user_activation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
      reschedule_job(args)
  end

  defp reschedule_job(args) do
    ApiWeb.Utils.PushNotification.send_push_notification(args)
    args
    |> PushNotificationSignupWorker.new(schedule_in: 604800)
    |> Oban.insert()
  end

end
