defmodule Api.Workers.PushNotificationEventWorker do
  use Oban.Worker, queue: :user_activation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    ApiWeb.Utils.PushNotification.send_push_notification(args)
  end

end
