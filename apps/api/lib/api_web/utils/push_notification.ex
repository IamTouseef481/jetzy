defmodule ApiWeb.Utils.PushNotification do
  alias Data.Context
  alias Data.Context.{NotificationTypes, UserInstalls, NotificationsRecords, NotificationSettings}

  alias Data.Schema.{
    NotificationType,
    PushNotificationLog,
    NotificationsRecord,
    User,
    NotificationSetting
  }
  alias ApiWeb.Presence
  alias ApiWeb.Api.V1_0.PushNotificationView

  def send_push_to_users(user_ids, notification_params) do
    Enum.each(
      user_ids,
      fn user_id ->
        send_push_notification(Map.put(notification_params, "user_id", user_id))
      end
    )
  end

  def send_push_notification(params) do
    try do
      Task.start(fn ->
        with true <- get_or_create_notification_settings(params["user_id"], params["event"]),
             fcm_tokens <- UserInstalls.get_fcm_token_by_user_id(params["user_id"]),
             %NotificationType{} = data <- NotificationTypes.get_notification_type_by_event(params["event"]),
             notification_message <- get_notification_message(params, data),
             body <- send_push(fcm_tokens, notification_message, params),
             _ <- create_push_log(params, data, notification_message, fcm_tokens),
             params <- modify_params(params),
             _ <- create_notification_record(params, notification_message),
             _ <- broadcast_to_user(params) do
          body
        else
          false -> {:error, "Found false in Notification Settings"}
          nil -> {:error, "No Notification Message Found"}
          [] -> {:error, "error in sending notification"}
          _ -> {:ok, [""]}
        end
      end)
    rescue
      _all ->
        {:ok, [""]}
    end
  end

  defp send_push(fcm_tokens, notification_message, params) do
    Enum.map(fcm_tokens, fn
        fcm_token when fcm_token in [nil, ""] ->
          nil
        fcm_token ->
          Fcmex.push(
            fcm_token,
            notification: %{
              title: nil,
              body: notification_message,
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              icon: "icon",
              badge: NotificationsRecords.get_unread_notifications_count(params["user_id"])
            },
            data: %{
              id: nil,
              description: params["description"],
              title: params["title"],
              receiverId: params["user_id"],
              senderId: params["sender_id"],
              isRead: false,
              insertedAt: DateTime.utc_now(),
              user: PushNotificationView.get_user_short_params(params["sender_id"]),
              event: params["event"],
              resourceId: params["resource_id"]
            }
          )
      end
    )
  end

  defp get_notification_message(params, data) do
    params["event"] == "feed_post_comment" ||
      (params["event"] == "event_comments" &&
         make_notification_message_for_feed_post_comment(
           params["keys"],
           data.message,
           params["user_id"],
           params["sender_id"],
           params["owner_id"],
           params["event"]
         )) ||
      make_notification_message(params["keys"], data.message, params["event"])
  end

  def make_notification_message(keys, message, event) do
    keys = if Map.has_key?(keys, "first_name") && Map.has_key?(keys, "last_name") do
      Map.drop(keys, ["first_name", "last_name"])
    |> Map.merge(%{"full_name" => make_full_name_string(keys["first_name"], keys["last_name"])})
    else
      keys
    end

    Enum.reduce(
      keys,
      message,
      fn
        {"room_name" = k, v}, message when event == "incoming_group_message" ->
          String.replace(message, "{{#{k}}}", v || "group")

        {"room_name" = k, v}, message when event == "incoming_event_message" ->
          String.replace(message, "{{#{k}}}", v || "private event group")

        {k, v}, message ->
          String.replace(message, "{{#{k}}}", v || "")
      end
    )
  end

  def make_full_name_string(first_name, last_name) do
    cond do
      is_nil(first_name) && is_nil(last_name) -> "Someone"
      is_nil(first_name) -> last_name
      is_nil(last_name) -> first_name
      true -> first_name <> " " <> last_name
    end
  end

  def make_notification_message_for_feed_post_comment(
        %{"first_name" => first_name, "last_name" => last_name} = keys,
        message,
        receiver_id,
        sender_id,
        owner_id,
        event
      ) do
    keys =
      Map.drop(keys, ["first_name", "last_name"])
      |> Map.merge(%{"full_name" => make_full_name_string(first_name, last_name)})

    msg =
      Enum.reduce(
        keys,
        message,
        fn {k, v}, message ->
          String.replace(message, "{{#{k}}}", v || "Someone")
        end
      )

    (event == "feed_post_comment" &&
       cond do
         sender_id == owner_id ->
           String.replace(msg, "your", "his")

         receiver_id != owner_id ->
           %User{first_name: first_name} = Context.get(User, owner_id)
           String.replace(msg, "your", first_name <> "'s")

         true ->
           msg
       end) ||
      cond do
        sender_id == owner_id ->
          String.replace(msg, "your", "his Post")

        receiver_id != owner_id ->
          %User{first_name: first_name} = Context.get(User, owner_id)
          String.replace(msg, "your", first_name <> "'s Post")

        true ->
          msg
      end
  end

  defp create_push_log(params, data, notification_message, fcm_tokens) do
    Enum.map(
      fcm_tokens,
      fn fcm_token ->
        Context.create(
          PushNotificationLog,
          %{
            receiver_id: params["user_id"],
            notification_type_id: data.id,
            push_message: notification_message,
            device_id: fcm_token,
            sender_id: params["sender_id"]
          }
        )
      end
    )
  end

  defp create_notification_record(params, notification_message) do
    Context.create(
      NotificationsRecord,
      %{
        description: notification_message,
        receiver_id: params["user_id"],
        sender_id: params["sender_id"],
        type: params["event"],
        resource_id: params["resource_id"],
        is_opened: params["is_opened"]
      }
    )
  end

  def schedule_push_notification(:profile_reminder, user) do
      push_notification_params = %{
        "keys" => %{},
        "event" => "profile_reminder", "user_id" => user.id, "schedule_time" => 1,
        "worker_name" => Api.Workers.PushNotificationSignupWorker ,
        "sender_id" => user.id
      }
      schedule_push_notification(push_notification_params)
  end
  
  def schedule_push_notification(params) do
    params
    |> params["worker_name"].new(schedule_in: params["schedule_time"])
    |> Oban.insert()
  end

  def create_notification_settings(user_id) do
    Task.start(fn ->
      notification_type_ids = NotificationTypes.get_notification_type_ids()

      Enum.each(notification_type_ids, fn notification_type_id ->
        case Context.get_by(NotificationSetting,
               user_id: user_id,
               notification_type_id: notification_type_id
             ) do
          nil ->
            Context.create(
              NotificationSetting,
              %{
                user_id: user_id,
                notification_type_id: notification_type_id,
                is_send_notification: true,
                is_send_mail: true
              }
            )

          data ->
            :ok
        end
      end)
    end)
  end

  def get_or_create_notification_settings(user_id, event) do
    case NotificationSettings.check_is_send_notification(user_id, event) do
      %{is_send_notification: true} ->
        true

      %{is_send_notification: false} ->
        false

      nil ->
        case NotificationTypes.get_notification_type_id(event) do
          nil ->
            false

          notification_type_id ->
            true

            Context.create(
              NotificationSetting,
              %{
                user_id: user_id,
                notification_type_id: notification_type_id,
                is_send_notification: true,
                is_send_mail: true
              }
            )

            true
        end
    end
  end

  # ----------------------------------------------------------------------------
  # soft_delete_follow_notification/3
  # ----------------------------------------------------------------------------

  def soft_delete_push_notification(sender_id, receiver_id, types) do
    if is_list(receiver_id) do
      Enum.each(
        receiver_id,
        fn user_id ->
          NotificationsRecords.delete_push_notification(sender_id, user_id, types)
        end
      )
    else
      NotificationsRecords.delete_push_notification(sender_id, receiver_id, types)
    end
  end

  defp broadcast_to_user(params) do
    if params["is_opened"] == false do
      ApiWeb.Endpoint.broadcast(
        "user:" <> params["user_id"],
        "unread_notification_count",
        %{
          unread_notification_count:
            NotificationsRecords.get_unread_notifications_count(params["user_id"])
        }
      )
    end
  end

  defp modify_params(params) do
    case Presence.get_active_users("notification:"<>params["user_id"]) do
     [] -> Map.put(params, "is_opened", false)
     _ -> Map.put(params, "is_opened", true)
    end
  end
end
