defmodule ApiWeb.Utils.Email do

  alias Api.Mailer
  alias Data.Context.{NotificationTypes}
  alias Data.Schema.{NotificationType, User}
  alias Data.Context
  alias Data.Context.NotificationSettings

  def send_emails_to_users(user_ids, params) do
    Enum.each(
      user_ids,
      fn user_id ->
        %{email: email} = Context.get(User, user_id)
        send_email(%{first_name: params["first_name"], email: email}, Map.put(params, "user_id", user_id))
      end
    )
  end


  def send_email(user, %{"event" => event} = params) do
    try do
      if Map.has_key?(params, "shareable_link") do
        with true <- get_or_create_notification_settings(params["user_id"], params["event"]),
            %NotificationType{} = data <- NotificationTypes.get_notification_type_by_event(params["event"]),
             notification <- ApiWeb.Utils.PushNotification.make_notification_message(params["keys"], data.message, event),
             {:ok, _pid} <- Mailer.send_email_with_user_link(user, %{notification: notification, template_name: params["template_name"], shareable_link: params["shareable_link"], subject: params["subject"]}) do
          {:ok , "email sent successfully"}
        else
          false -> {:error, "Found false in Notification Settings"}
          nil -> {:error, "No Notification Message Found against this event"}
          {:error, _error} -> {:error, "error in sending email"}
        end
      else
        with true <- get_or_create_notification_settings(params["user_id"], params["event"]),
            %NotificationType{} = data <- NotificationTypes.get_notification_type_by_event(params["event"]),
             notification <- ApiWeb.Utils.PushNotification.make_notification_message(params["keys"], data.message, event),
             {:ok, _pid} <- Mailer.send_email(user, %{notification: notification, template_name: params["template_name"]}) do
          {:ok , "email sent successfully"}
        else
          false -> {:error, "Found false in Notification Settings"}
          nil -> {:error, "No Notification Message Found against this event"}
          {:error, _error} -> {:error, "error in sending email"}
        end
      end

    rescue
      _ -> {:ok, [""]}
    end
  end

  def get_or_create_notification_settings(user_id, event) do
    case NotificationSettings.check_is_send_notification(user_id, event) do
      %{is_send_mail: true} -> true
      %{is_send_mail: false} -> false
       nil -> case NotificationTypes.get_notification_type_id(event) do
        nil -> false
        notification_type_id -> Context.create(NotificationSetting,
          %{
            user_id: user_id,
            notification_type_id: notification_type_id,
            is_send_notification: true,
            is_send_mail: true
            })
            true
      end
    end
  end

end
