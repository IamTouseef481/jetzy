defmodule Api.Workers.SignupWorker do
  use Oban.Worker, queue: :user_activation, max_attempts: 1

  alias Data.Context
  alias Data.Schema.User
  alias Api.Mailer
  alias ApiWeb.Utils.Common

  @verification_url Application.get_env(:api, :sendgrid)[:email_verification_url]



  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = args}) do
    case args do
      %{"in_the" => "signup_email"} ->
        user = Context.get(User, id)

        if user && is_nil(user.email) == false do
          with verification_token <- Common.generate_token(),
               {:ok, %User{} = user} <-
                 Context.update(User, user, %{verification_token: verification_token}) do
            Mailer.send_verify_email(
              user,
              "#{@verification_url}#{id}"
            )
            Mailer.send_welcome_email(
              user
            )
          end
        else
          {:ok, user}
        end
    end

    :ok
  end
end
