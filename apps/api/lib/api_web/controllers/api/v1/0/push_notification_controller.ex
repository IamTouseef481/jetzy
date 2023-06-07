#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.PushNotificationController do
  @moduledoc """
  Get and update user notificaitons.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context.NotificationsRecords
  alias Data.Schema.NotificationsRecord
  alias Data.Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  #  index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/notification-status"
    summary "Get List OF read and unread notification"
    description "Get List OF Read and Unread notification"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      page(:query, :integer, "Page no.", required: true)
    end
    response 200, "Ok", Schema.ref(:ListNotification)
  end

  @doc """
  Get active user's read/unread notifications.
  """
  def index(conn, %{"page" => page} = _params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    case NotificationsRecords.get_user_notifications(current_user_id, page) do
      data -> render(conn, "notification_paging.json", %{notifications: data, current_user_id: current_user_id})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/notification-status"
    summary "Update Notification Status"
    description "Update Status of read and unread notification"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:UpdateNotificationStatus), "Update Push Notification Params", required: true
    end
    response 200, "Ok", Schema.ref(:UpdateNotificationStatus)
  end

  @doc """
  Update read/unread status of active user's notifications.
  """
  def create(conn, params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    result = Enum.reduce(params["notification_ids"], [], fn  notification_id, acc ->
      with %NotificationsRecord{} = notification_record <-
             NotificationsRecords.get_notification_record_by_notification_id(notification_id, current_user_id),
           {:ok, updated_record} <-
             Context.update(NotificationsRecord, notification_record, %{is_read: params["is_read"]}) do
        [updated_record | acc]
      else
        _ -> acc
      end
    end)
    render(conn, "notifications.json", %{notifications: result})
  end
  
  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
  %{
    UpdateNotificationStatus: swagger_schema do
      title "Update Post Type"
      description "Update Post Type"
      properties do
        notification_id :string, "ID"
        is_read :boolean, true
      end
      example %{
        is_read: true,
        notification_ids: ["b640adbb-75a8-47a7-b3b6-77ef718d2a11", "b640adbb-75a8-47a7-b3b6-77ef718d2a11"]
      }
      end,
    ListNotification: swagger_schema do
      title "List of Notifications"
      description "List of Notifications"
      example(
       %{
         ResponseData: %{
           unreadNotifications: 36,
           pagination: %{
             totalRows: 27,
             totalPages: 3,
             page: 1
           },
         data: [
         %{
         user: %{
           firstName: "super",
           lastName: "admin",
           image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
           id: "a711bf85-963f-42ed-9728-c2047d5694fb",
           baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
          },
           senderId: "a711bf85-963f-42ed-9728-c2047d5694fb",
           resourceId: "9f096f1c-e677-4e19-a0eb-291a89492da1",
           receiverId: "a711bf85-963f-42ed-9728-c2047d5694fb",
           isRead: false,
           insertedAt: "2022-03-01T09:05:38Z",
           id: "ef193124-d1b5-43f4-a6d5-63dc7e7f4f20",
           event: "events_comming_soon",
           description: "Your event Trip to Neelum Valley is close, are you excited!"
         },
           %{
             user: %{
               firstName: "super",
               lastName: "admin",
               image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
               id: "a711bf85-963f-42ed-9728-c2047d5694fb",
               baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
             },
             senderId: "a711bf85-963f-42ed-9728-c2047d5694fb",
             resourceId: "9f096f1c-e677-4e19-a0eb-291a89492da1",
             receiverId: "a711bf85-963f-42ed-9728-c2047d5694fb",
             isRead: false,
             insertedAt: "2022-03-01T09:05:38Z",
             id: "72e6c8d3-87cf-4101-be20-e1892cb3ee4e",
             event: "events_by_me",
             description: "Congratulations, you have succesfully created an event on Jetzy for Date 2022-01-07"
           }
         ]
         }
       }
      )
    end
  }
  end

end
