#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.CommentController do
  @moduledoc """
  API for managing post comments.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  alias Data.Context
  alias Data.Schema.{RoomMessage, UserEvent, User}
  alias Data.Context.{RoomMessages, UserRoles}
  alias ApiWeb.Utils.Common

  #============================================================================
  # Macro Constants
  #============================================================================
  @event "feed_post_comment"
  @template_name  "notification_email.html"

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/post/{post_id}/comments"
    summary "Get List Of Comments"
    description "Get List OF Comments"
    produces "application/json"
    parameters do
      post_id :path, :string, "Post ID", required: true
      page(:query, :integer, "Page no.", required: true)

    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListComment)
  end
  @doc """
  Return Post's Comments.
  """
  def index(conn, %{"post_id" => post_id, "page" => page}) do
    current_user_id = case Api.Guardian.Plug.current_resource(conn) do
                        %{id: current_user_id} -> current_user_id
                        _ -> nil
                      end
    with %UserEvent{} = post <- Context.get(UserEvent, post_id),
         comments <- RoomMessages.list_by(RoomMessage, post.room_id, page) do
      user_comments = RoomMessages.preload_all(comments.entries)
      render(conn, "comments.json", %{post_id: post_id, comments: Map.merge(comments, %{entries: user_comments}), current_user_id: current_user_id})
    else
      nil -> render(conn, "comment.json", %{error: "Post Does not exist"})
      _ -> render(conn, "comment.json", %{error: "Something went wrong..."})
    end
  end

  #----------------------------------------------------------------------------
  # guest_index/2
  #----------------------------------------------------------------------------
  swagger_path :guest_index do
    get "/v1.0/guest/post/{post_id}/comments"
    summary "Get List Of Comments for guest user"
    description "Get List OF Comments for guest user"
    produces "application/json"
    parameters do
      post_id :path, :string, "Post ID", required: true
      page(:query, :integer, "Page no.", required: true)

    end
    response 200, "Ok", Schema.ref(:ListComment)
  end
  @doc """
  Return Post Comments with Guest Level Authentication.
  """
  def guest_index(conn, %{"post_id" => _post_id, "page" => _page} = params) do
    index(conn, params)
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  # @todo delete or update by may 2022
  #  swagger_path :show do
  #    get "/v1.0/post/{post_id}/comments/{id}"
  #    summary "Get RoomMessage By"
  #    description "Get RoomMessage By"
  #    produces "application/json"
  #    security [%{Bearer: []}]
  #    parameters do
  #      id :path, :string, "RoomMessage ID", required: true
  #    end
  #    response 200, "Ok", Schema.ref( :RoomMessage )
  #  end
  @doc """
  Show specific post comment.
  @todo update swagger entry
  """
  def show(conn, %{"id" => id}) do
    current_user_id = case Api.Guardian.Plug.current_resource(conn) do
                        %{id: user_id} -> user_id
                        nil -> nil
                      end
    case Context.get(RoomMessage, id) |> RoomMessages.preload_all() do
      nil -> render(conn, "comment.json", %{error: ["comment does not exist"]})
      %{} = comment -> render(conn, "comment.json", %{comment: comment, current_user_id: current_user_id})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  # @todo delete or update by may 2022
    swagger_path :create do
      post "/v1.0/post/{post_id}/comments"
      summary "Create RoomMessage"
      description "Create RoomMessage by giving the ID of the post and write your comment in the body. user_id param is optional and is used for admin"
      produces "application/json"
      security [%{Bearer: []}]
      parameters do
        post_id :path, :string, "Post ID", required: true
        body :body, Schema.ref( :CreateComment ), "Create RoomMessage params", required: true
      end
      response 200, "Ok", Schema.ref( :RoomMessage )
    end
  @doc """
  Create Post Comment
  @todo update swagger entry
  """

  def create(conn, %{"user_id" => user_id} = params) do
    %{id: current_user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    with true <- "admin" in UserRoles.get_roles_by_user_id(current_user_id),
          %User{first_name: first_name, last_name: last_name} = user <- Context.get(User, user_id) do
      case create_comment(user_id, first_name, last_name, params, conn) do
        {:ok, %RoomMessage{} = comment} ->
          render(conn, "comment.json", %{comment:
            Map.merge(comment, %{current_user_id: current_user_id}) |> RoomMessages.preload_all()})
        {:error, error} ->
          render(conn, "comment.json", %{error: error})
        {:error, error, %RoomMessage{} = comment} ->
          Context.delete(comment)
          render(conn, "comment.json", %{error: error})
      end

      else
      false -> render(conn, "comment.json", %{error: "You are not authorized"})
      nil -> render(conn, "comment.json", %{error: "User not found"})
    end
  end

  def create(conn, params) do
    %{id: sender_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    case create_comment(sender_id, first_name, last_name, params, conn) do
      {:ok, %RoomMessage{} = comment} ->
        render(conn, "comment.json", %{comment:
              Map.merge(comment, %{current_user_id: sender_id}) |> RoomMessages.preload_all()})
      {:error, error} ->
        render(conn, "comment.json", %{error: error})
      {:error, error, %RoomMessage{} = comment} ->
        Context.delete(comment)
        render(conn, "comment.json", %{error: error})
    end
  end

  defp create_comment(sender_id, first_name, last_name, params, conn) do
    with %UserEvent{} = post <- Context.get(UserEvent, params["post_id"]) || :post_not_found,
         {:ok, comment} <- Context.create(RoomMessage, Map.merge(params, %{"sender_id"=> sender_id, "room_id"=> post.room_id})),
         _ <- ApiWeb.Utils.Common.update_points(sender_id, :commented_on_a_post),
         %{} = user <- Data.Context.UserEvents.get_user_by_event_id(params["post_id"]) || {:user_not_found, comment} do
      user_ids = RoomMessages.get_user_ids_commented_on_specific_post(post, sender_id)
      push_notification_params = %{
        "keys" => %{
          "first_name" => first_name, "last_name" => last_name
        },
        "event" => @event,
        "template_name" => @template_name,
        "sender_id" => sender_id,
        "resource_id" => params["post_id"],
        "owner_id" => user.id
      }
      #      push_notification_params = RoomMessages.get_push_notification_params(first_name, @event, user, @template_name, sender_id, params["post_id"])
      Jetzy.Module.Telemetry.Analytics.comment_created(conn, sender_id, comment)
      ApiWeb.Utils.PushNotification.send_push_to_users(user_ids, push_notification_params)
      #      Task.async(ApiWeb.Utils.PushNotification, :send_push_to_users, [user_ids, push_notification_params])
      #      Task.async(ApiWeb.Utils.Email, :send_emails_to_users, [user_ids, push_notification_params])
      ApiWeb.Utils.Email.send_emails_to_users(user_ids, push_notification_params)
      {:ok, comment}
    else
      {:error, error} -> {:error, error}
      [:user_not_found, comment] -> {:error, "Post owner not found", comment}
      :post_not_found -> {:error, "Post not found"}
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/post/{post_id}/comments/{id}"
    summary "Update RoomMessage"
    description "Update RoomMessage by giving the ID of the post and write your comment in the body"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "RoomMessage ID", required: true
    end
    parameters do
      body :body, Schema.ref(:UpdateComment), "Update RoomMessage Params", required: true
    end
    response 200, "Ok", Schema.ref(:RoomMessage)
  end
  @doc """
  Update Post Comment
  """
  def update(conn, %{"id" => id} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RoomMessage{sender_id: sender_id} = comment <- Context.get(RoomMessage, id),
         true <- current_user_id == sender_id || "admin" in UserRoles.get_roles_by_user_id(current_user_id),
         {:ok, %RoomMessage{} = comment} <- Context.update(RoomMessage, comment, Map.drop(params, ["post_id"])) do
      render(
        conn,
        "comment.json",
        %{comment: comment |> RoomMessages.preload_all(), current_user_id: current_user_id
        }
      )
    else
      nil -> render(conn, "comment.json", %{error: ["RoomMessage not found"]})
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "comment.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      false -> render(conn, "comment.json", %{error: "You are not authorized"})
      {:error, error} -> render(conn, "comment.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/post/{post_id}/comments/{id}"
    summary "Delete RoomMessage"
    description "Delete RoomMessage"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "RoomMessage ID", required: true
    end
    response 200, "Ok", Schema.ref( :RoomMessage )
  end
  @doc """
  Delete Post Comment
  """
  def delete(conn, %{"id" => id} = _params) do #TODO - on deleting a comment, all its replies should also be deleted...
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RoomMessage{sender_id: sender_id} = comment <- Context.get(RoomMessage, id),
         true <- current_user_id == sender_id || "admin" in UserRoles.get_roles_by_user_id(current_user_id),
         %UserEvent{} = user_event <- Context.get_by(UserEvent, [room_id: comment.room_id]),
         {:ok, %RoomMessage{} = comment} <- Context.delete(comment) do
      comments_count = RoomMessages.count_room_messages(comment.room_id)
      payload = %{
      "comment" => %{
        "parentId" => comment.parent_id,
        "time" => comment.inserted_at,
        "id" => comment.id,
        "message" => comment.message,
        "callbackVerification" => comment.callback_verification,
        },
        "commentsCount" => comments_count
      }
      ApiWeb.Endpoint.broadcast("event_comments:#{comment.room_id}", "comment_deleted", payload)
      Common.broadcast_for_comment("user_profile:#{user_event.user_id}", user_event, comments_count)
      Common.broadcast_for_comment("jetzy_timeline", user_event, comments_count)
      render(conn, "comment.json", %{comment:
        Map.merge(comment, %{current_user_id: current_user_id}) |> RoomMessages.preload_all()})
    else
      nil -> render(conn, "comment.json", %{error: ["RoomMessage not found"]})
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "comment.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      false -> render(conn, "comment.json", %{error: "You are not authorized"})
      {:error, error} -> render(conn, "comment.json", %{error: error})
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      RoomMessage: swagger_schema do
                     title "RoomMessage Model"
                     description "RoomMessage Model"
                     properties do
                       id :string, "id", required: true
                       description :string, "RoomMessage"
                       updated_by :string, "Updated By"
                       parent_id :string, "Parent ID"
                     end
                     example(%{
                       id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                       description: "Outstanding!! Keep It Up.",
                       message_images: [
                         "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                         "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
                       base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
                       replies_count: 2,
                       user: %{
                         userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                         first_name: "First name",
                         last_name: "Last name",
                         user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
                       },
                       replies: [
                         %{
                           id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                           comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                           inserted_at: "",
                           updated_at: "",
                           description: "Thanks",
                           message_images: [
                             "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                             "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
                           base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
                           user: %{
                             userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                             first_name: "First Name",
                             last_name: "Last Name",
                             user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                           }
                         },
                       ]
                     })
                   end,
      ListComment: swagger_schema do
                     title "List OF Comments"
                     description "List Of Comments"
                     example(%{responseData: %{
                       pagination: %{
                         total_pages: 2,
                         page: 1,
                         total_rows: 10
                       },
                       data: [
                         %{
                           id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                           description: "Outstanding!! Keep It Up.",
                           message_images: [
                             "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                             "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
                           base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
                           replies_count: 2,
                           user: %{
                             userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                             first_name: "First name",
                             last_name: "Last name",
                             user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
                           },
                           replies: [
                             %{
                               id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                               comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                               inserted_at: "",
                               updated_at: "",
                               description: "Thanks",
                               message_images: [
                                 "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                                 "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
                               base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
                               user: %{
                                 userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                                 first_name: "First Name",
                                 last_name: "Last Name",
                                 user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                               }
                             },
                           ]
                         }
                       ]
                     }})
                   end,
      CreateComment: swagger_schema do
                       title "Create RoomMessage"
                       description "Create RoomMessage"
                       properties do
                         message :string, "RoomMessage"
                         updated_by :string, "Updated By"
                         user_id :string, "User id"
                       end
                       example %{
                         parent_id: nil,
                         message: "Perfect!!.",
                         updated_by: nil,
                          user_id: "3f665047-9373-4335-9d39-3099a0eb85ba"
                       }
                     end,
      UpdateComment: swagger_schema do
                       title "Update RoomMessage"
                       description "Update RoomMessage"
                       properties do
                         message :string, "RoomMessage"
                         updated_by :string, "Updated By"
                       end
                       example %{
                         parent_id: nil,
                         message: "Perfect!!.",
                         updated_by: nil
                       }
                     end
    }
  end
end
