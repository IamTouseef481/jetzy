defmodule Data.Context.NotificationSettings do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{NotificationSetting, NotificationType}

  @spec preload_all(NotificationSetting.t()) :: NotificationSetting.t()
  def preload_all(data), do: Repo.preload(data, [:user, :notification_type, ])

  def check_is_send_notification(user_id, event) do
    NotificationSetting
    |> join(:inner, [ns], nt in NotificationType, on: nt.id == ns.notification_type_id)
    |> where([ns, nt], ns.user_id == ^user_id and nt.event == ^event)
    |> select([ns, _nt], %{is_send_notification: ns.is_send_notification, is_send_mail: ns.is_send_mail})
    |> Repo.one
  end

  def get_notification_setting(user_id, page, page_size \\ 10) do
    NotificationSetting
    |> where([ns], ns.user_id == ^user_id)
    |> preload([:notification_type])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_notification_setting_by_id(id) do
    NotificationSetting
    |> where([ns], ns.id == ^id)
    |> preload([:notification_type])
    |> Repo.one
  end

end
