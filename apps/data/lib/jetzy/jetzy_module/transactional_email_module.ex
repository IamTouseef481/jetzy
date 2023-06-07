defmodule JetzyModule.TransactionalEmailModule do
  @moduledoc """
  Manage preparing outgoing transactional emails.
  """
  alias Api.Workers.{WelcomeEmailWorker}
  
  def welcome_email(user, context, options \\ []) do
      job = %{id: user.id, in_the: "welcome_email"}
      |> WelcomeEmailWorker.new(schedule_in: 5)
      |> Oban.insert()
      {:ok, job}
  end
  
end