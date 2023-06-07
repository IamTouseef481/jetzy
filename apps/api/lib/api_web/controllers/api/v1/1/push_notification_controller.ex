#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_1.PushNotificationController do
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
    get "/v1.1/notifications"
    summary "Get List Of read and unread notification"
    description "Get List Of Read and Unread notification"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      after_record :query, :string, "Since Record", required: false
      rpp :query, :integer, "records to include", required: false, default: "100"
    end
    response 200, "Ok", Schema.ref(:NotificationList)
  end

  @doc """
  Get active user's read/unread notifications.
  """
  def index(conn, params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    context = Noizu.ElixirCore.CallingContext.system()
    vnext_user = Jetzy.User.Repo.by_guid!(current_user_id, context, [])
    data = Jetzy.User.Notification.Event.Repo.query(vnext_user, params["after_record"], params["rpp"], context, [])
    render(conn, "notifications.json", %{repo: data})
  end

  #----------------------------------------------------------------------------
  #  meta_data/2
  #----------------------------------------------------------------------------
  swagger_path :meta_data do
    get "/v1.1/notifications/meta"
    summary "Get notification meta"
    description "Get read/unread/total counts"
    produces "application/json"
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:NotificationMeta)
  end

  @doc """
  Get active user's read/unread notifications.
  """
  def meta_data(conn, params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    context = Noizu.ElixirCore.CallingContext.system()
    vnext_user = Jetzy.User.Repo.by_guid!(current_user_id, context, [])
    data = Jetzy.User.Notification.Event.Repo.meta_data(vnext_user, context, [])
    render(conn, "notifications_meta.json", %{meta: data})
  end

  #----------------------------------------------------------------------------
  #  clear/2
  #----------------------------------------------------------------------------
  swagger_path :clear do
    put "/v1.1/notifications/{ref}/clear"
    summary "Cear Event"
    description "Clear event from list"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      ref :path, :string, "Entity ref", required: true
    end
    response 200, "Ok", Schema.ref(:NotificationEntity)
  end
  @doc """
  Get active user's read/unread notifications.
  """
  def clear(conn, %{"ref" => ref} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    context = Noizu.ElixirCore.CallingContext.system()
    entity = Noizu.ERP.entity!(ref)
    data = Jetzy.User.Notification.Event.Entity.mark_cleared(entity, context, [])
    render(conn, "show.json", %{entity: data})
  end

  #----------------------------------------------------------------------------
  #  clear/2
  #----------------------------------------------------------------------------
  swagger_path :read do
    put "/v1.1/notifications/{ref}/read"
    summary "Mark Event Viewed"
    description "Mark event as viewed"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      ref :path, :string, "Entity ref", required: true
    end
    response 200, "Ok", Schema.ref(:NotificationEntity)
  end
  @doc """
  Get active user's read/unread notifications.
  """
  def read(conn, %{"ref" => ref} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    context = Noizu.ElixirCore.CallingContext.system()
    entity = Noizu.ERP.entity!(ref)
    data = Jetzy.User.Notification.Event.Entity.mark_read(entity, context, [])
    render(conn, "show.json", %{entity: data})
  end


  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      NotificationMeta: swagger_schema do
                          title "Notification Meta Data"
                          description "Total, Events, Unread, Cleared, Read"
                          example(
                            %{
                              total_events: 1,
                              total_unread: 2,
                              total_read: 3,
                              total_cleared: 5
                            }
                          )
                        end,
      NotificationEntity: swagger_schema do
                          title "Single Notification Entity"
                          description "NotificationEntity"
                          example(
                            %{
                              user: %{
                                firstName: "super",
                                lastName: "admin",
                                image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.jpg",
                                thumb: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.thumb.jpg",
                                blur_hash: "azx",
                                id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                              },
                              sender: %{
                                firstName: "sender",
                                lastName: "from",
                                image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.jpg",
                                thumb: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.thumb.jpg",
                                blur_hash: "azx",
                                id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                              },
                              subject: "ref.string.id",
                              status: "pending|cleared|viewed",
                              created_on: "2022-03-01T09:05:38Z",
                              modified_on: "2022-03-01T09:05:38Z",
                              deleted_on: "2022-03-01T09:05:38Z",
                              id: "ref.string.id",
                              template: "Event {{sender.name}} template string",
                              notification_type: "atom_name"
                            }
                          )
                        end,
      NotificationList: swagger_schema do
                          title "List of Notifications"
                          description "List of Notifications"
                          example(
                            %{
                              ResponseData: %{
                                length: 36,
                                entities: [
                                  %{
                                    user: %{
                                      firstName: "super",
                                      lastName: "admin",
                                      image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.jpg",
                                      thumb: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.thumb.jpg",
                                      blur_hash: "azx",
                                      id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                                    },
                                    sender: %{
                                      firstName: "sender",
                                      lastName: "from",
                                      image: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.jpg",
                                      thumb: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d.thumb.jpg",
                                      blur_hash: "azx",
                                      id: "a711bf85-963f-42ed-9728-c2047d5694fb",
                                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                                    },
                                    subject: "ref.string.id",
                                    status: "pending|cleared|viewed",
                                    created_on: "2022-03-01T09:05:38Z",
                                    modified_on: "2022-03-01T09:05:38Z",
                                    deleted_on: "2022-03-01T09:05:38Z",
                                    id: "ref.string.id",
                                    template: "Event {{sender.name}} template string",
                                    notification_type: "atom_name"
                                  },
                                ]
                              }
                            }
                          )
                        end
    }
  end

end
