defmodule ApiWeb.Api.V1_0.NotificationSettingView do
  @moduledoc false
  use ApiWeb, :view
#  alias Data.Context
  alias ApiWeb.Api.V1_0.NotificationSettingView

  def render("index.json", %{notification_settings: notification_settings}) do
    data = render_many(notification_settings, NotificationSettingView, "notification_setting.json", as: :notification_setting)
    page_data = %{
      total_rows: notification_settings.total_entries,
      page: notification_settings.page_number,
      total_pages: notification_settings.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("notification_setting.json", %{notification_setting: notification_setting}) do
    %{
      id: notification_setting.id,
      user_id: notification_setting.user_id,
      notification_type_id: notification_setting.notification_type_id,
      is_send_notification: notification_setting.is_send_notification,
      is_send_mail: notification_setting.is_send_mail,
      description: notification_setting.notification_type.description
    }
  end

  def render("message.json", %{message: message}) do
    message
  end

end
