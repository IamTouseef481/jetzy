defmodule ApiWeb.Api.V1_0.PushNotificationView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.PushNotificationView
  alias Data.Context.NotificationsRecords
  alias Data.Context
  alias Data.Schema.User

  def render("notifications.json", %{notifications: notifications}) do
    notification_data = render_many(notifications, PushNotificationView, "show.json", as: :notification)
    %{data: notification_data}
  end

  def render("notification_paging.json", %{notifications: notifications, current_user_id: current_user_id}) do
    notification_data = render_many(notifications, PushNotificationView, "show.json", as: :notification)
    unread_count = NotificationsRecords.get_unread_notifications_count(current_user_id)
    page_data = %{
      total_rows: notifications.total_entries,
      page: notifications.page_number,
      total_pages: notifications.total_pages
    }
    %{data: notification_data, pagination: page_data, unread_notifications: unread_count}
  end

  def render("show.json", %{notification: notification}) do
    %{
      id: notification.id,
      description: notification.description,
      receiver_id: notification.receiver_id,
      sender_id: notification.sender_id,
      is_read: notification.is_read,
      inserted_at: notification.inserted_at,
      user: get_user_short_params(notification.sender_id),
      event: notification.type,
      resource_id: notification.resource_id
    }
  end

  def get_user_short_params(sender_id) do
    case Context.get(User, sender_id) do
      %User{is_deactivated: false, deleted_at: nil, is_self_deactivated: false} = user ->
        %{
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          image: user.image_name
        }
        _ -> nil
    end
  end
end