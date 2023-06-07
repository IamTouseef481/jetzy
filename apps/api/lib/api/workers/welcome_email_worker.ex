defmodule Api.Workers.WelcomeEmailWorker do
  use Oban.Worker, queue: :user_activation, max_attempts: 1

  alias Data.Context
  alias Data.Schema.User
  alias Api.Mailer
  alias ApiWeb.Utils.Common

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = args}) do
    case args do
      %{"in_the" => "welcome_email"} ->
        user = Context.get(User, id)

        if user && is_nil(user.email) == false do
            Mailer.send_welcome_email(
              user
            )
          end
    end
    :ok
  end
end
