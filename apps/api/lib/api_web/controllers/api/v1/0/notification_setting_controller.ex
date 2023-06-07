#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.NotificationSettingController do
  @moduledoc """
  Manage post/notification_settings/update notification settings.
  @todo hook into vnext like engine.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Schema.{NotificationSetting}
  alias Data.Context.NotificationSettings

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/notification-setting/{id}")
    summary("Update Notification Setting")
    description("Update Notification Setting")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Notification Setting ID", required: true)
      body(:body, Schema.ref(:UpdateNotificationSetting), "Update Notification Setting Params", required: true)

    end

    response(200, "Ok", Schema.ref(:UpdateResponse))
  end
  @doc """
  Update Notification Setting.
  """
  def update(conn, %{"id" => id} = params) do
    with %NotificationSetting{} = notification_setting <- NotificationSettings.get_notification_setting_by_id(id),
      {:ok, updated_data} <- Context.update(NotificationSetting, notification_setting, params) do
        render(conn, "notification_setting.json", %{notification_setting: updated_data})
      else
        nil -> render(conn, "message.json", %{message: "Record Not Found"})
        {:error, _error} -> render(conn, "message.json", %{message: "Unable to Update data"})
      end
  end

   #----------------------------------------------------------------------------
  # index_for_listing_notification_setting/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/notification-setting")
    summary("Get List Notification Setting")
    description("Get List OF Notification Setting")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      page(:query, :integer, "Page no.", required: true)
    end
    response(200, "Ok", Schema.ref(:ListNotificationSetting))
  end
  @doc """
  List of Notification Setting
  """
  def index(conn, %{"page" => page}) do
    %{id: user_id} = _current_user = Api.Guardian.Plug.current_resource(conn)
    notification_settings = NotificationSettings.get_notification_setting(user_id, page)
    render(conn, "index.json", %{notification_settings: notification_settings})
  end


   #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      UpdateNotificationSetting: swagger_schema do
        title "Update Notification Setting"
        description "Update Notification Setting"
        properties do
          id :string, "Frequently Asked Question ID"
          id :string, "User ID"
          id :string, "Notification Type ID"
          is_send_notification :boolean, "true"
          is_send_mail :boolean, "true"
        end
        example %{
          is_send_notification: "true",
          is_send_mail: "false",
        }
      end,
      ListNotificationSetting:
        swagger_schema do
          title("Notification Settings")
          description("List Of Notification Settings")

          example(%{
            ResponseData: [
              %{
              userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
              notificationTypeId: "0c0a7258-84de-11ec-8d5d-6003089c0a9a",
              isSendNotification: false,
              isSendMail: true,
              id: "284fddbc-5e74-48b7-af98-34265f862f80"
            },
            %{
              userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
              notificationTypeId: "0c0a7258-84de-11ec-8d5d-6003089c0a9a",
              isSendNotification: true,
              isSendMail: false,
              id: "284fddbc-5e74-48b7-af98-34265f862f80"
            }
          ]
          })
        end,
        UpdateResponse:
        swagger_schema do
          title("Notification Settings")
          description("Notification Settings")

          example(%{
            ResponseData:
              %{
              userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
              notificationTypeId: "0c0a7258-84de-11ec-8d5d-6003089c0a9a",
              isSendNotification: false,
              isSendMail: true,
              id: "284fddbc-5e74-48b7-af98-34265f862f80"
            }
          })
        end,


    }
  end
end
