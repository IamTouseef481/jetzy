defmodule Data.Context.PushNotificationLogs do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.PushNotificationLog
  require Logger

  @spec preload_all(PushNotificationLog.t()) :: PushNotificationLog.t()
  def preload_all(data), do: Repo.preload(data, [:sender, :receiver, ])

  def delete_push_notification_logs_by_user_id(_, _, user_id) do
    try do
      PushNotificationLog
      |> where([pnl], pnl.sender_id == ^user_id or pnl.receiver_id == ^user_id)
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end

end
