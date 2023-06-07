#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.CommentReplyController do
  @moduledoc """
  Manage nested comment replies.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Schema.RoomMessage
  alias Data.Context.RoomMessages
  alias ApiWeb.Utils.Common

  #============================================================================
  # Macro Constants
  #============================================================================
  @event "feed_shoutout_comment_reply"
  @template_name "notification_email.html"

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/comments/{parent_sref}/replies"
    summary "Get List Of RoomMessage Replies"
    description "Get List OF RoomMessage Replies"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      parent_sref :path, :string, "Parent RoomMessage ID", required: true
      page(:query, :integer, "Page", required: true)
    end
    response 200, "Ok", Schema.ref(:ListReplies)
  end
  @doc """
  Get post comment replies.
  """
  def index(conn, %{"parent_sref" => parent_id, "page" => page}) do
    current_user_id = case Api.Guardian.Plug.current_resource(conn) do
                        %{id: current_user_id} -> current_user_id
                        _ -> nil
                      end
    case Context.get(RoomMessage, parent_id) do
      %RoomMessage{} ->
        comment_replies = RoomMessages.list_by_parent_id(RoomMessage, parent_id, page)
        entries = RoomMessages.preload_all(comment_replies.entries, [:sender, :parent])
        render(conn, "comment_replies.json", %{comment_replies: Map.merge(comment_replies, %{entries: entries}), current_user_id: current_user_id})
      nil -> render(conn, "comment_reply.json", %{error: "RoomMessage does not exist!"})
      _ -> render(conn, "comment_reply.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # guest_index/2
  #----------------------------------------------------------------------------
  swagger_path :guest_index do
    get "/v1.0/guest/comments/{parent_sref}/replies"
    summary "Get List Of RoomMessage Replies for guest"
    description "Get List OF RoomMessage Replies for guest"
    produces "application/json"
    parameters do
      parent_sref :path, :string, "Parent RoomMessage ID", required: true
      page(:query, :integer, "Page", required: true)
    end
    response 200, "Ok", Schema.ref(:ListReplies)
  end
  @doc """
  list post comment nested replies with Guest Level authentication
  @note Test123
  """
  def guest_index(conn, %{"parent_sref" => _parent_id, "page" => _page} = params) do
    index(conn, params)
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/comments/{parent_sref}/replies/{id}"
    summary "Get Reply By"
    description "Get Reply By"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "RoomMessage ID", required: true
    end
    response 200, "Ok", Schema.ref(:Reply)
  end
  @doc """
  Get post comment and nested replies.
  @todo Once the comment is deleted, all the replies should also be deleted
  """
  def show(conn, %{"id" => id}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    case Context.get(RoomMessage, id) |> RoomMessages.preload_all() do
      nil -> render(conn, "comment_reply.json", %{error: ["comment_reply does not exist"]})
      %{} = comment_reply -> render(conn, "comment_reply.json", %{comment_reply: comment_reply, current_user_id: current_user_id})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/comments/{parent_sref}/replies"
    summary "Create Reply"
    description "Create Reply by giving the ID of the post and write your comment in the body"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      parent_sref :path, :string, "Parent RoomMessage ID", required: true
      body :body, Schema.ref(:CreateComment), "Create Reply params", required: true
    end
    response 200, "Ok", Schema.ref(:Reply)
  end
  @doc """
  Create nested reply to post comment.
  """
  def create(conn, params) do
    updated_params =
      params
      |> Common.keys_to_atoms()
      |> Common.replace_map_key(:parent_sref, :parent_id)
    %{id: sender_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    reward_id = "16F8E47E-7449-436F-A846-ACFBD8D02569"
    with %RoomMessage{} = comment <- Context.get(RoomMessage, updated_params.parent_id),
         {:ok, comment_reply} <- Context.create(RoomMessage, Map.put(updated_params, :user_id, sender_id)),
         _ <- ApiWeb.Utils.Common.update_points(sender_id, :commented_on_a_post),
         %{} = user <- Data.Context.CommentReplies.get_user_by_parent_sref(params["parent_sref"]) do
      #            push_notification_params = RoomMessages.get_push_notification_params(first_name, @event, user, @template_name, sender_id, comment.shoutout_id)

      if comment.sender_id != sender_id do
        push_notification_params = %{
          "keys" => %{
            "first_name" => first_name,
            "last_name" => last_name
          },
          "event" => @event,
          "template_name" => @template_name,
          "user_id" => user.id,
          "sender_id" => sender_id,
          "resource_id" => comment.parent_id,
        }
        ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
        Jetzy.Module.Telemetry.Analytics.comment_created(conn, sender_id, comment_reply)
        ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: user.email}, push_notification_params |> Map.put("subject", "Comment reply"))
      end
      render(conn, "comment_reply.json", %{comment_reply: RoomMessages.preload_all(comment_reply)})
    else
      nil ->
        render(conn, "comment_reply.json", %{error: "RoomMessage does not exist"})
      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "comment_reply.json",
          %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)}
        )
      _ ->
        render(conn, "comment_reply.json", %{error: "Something went wrong...!"})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/comments/{parent_sref}/replies/{id}"
    summary "Update Reply"
    description "Update Reply by giving the ID of the post and write your comment in the body"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "RoomMessage ID", required: true
      body :body, Schema.ref(:UpdateComment), "Update Reply Params", required: true
    end
    response 200, "Ok", Schema.ref(:Reply)
  end
  @doc """
  Update nested comment reply.
  """
  def update(conn, %{"id" => id} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RoomMessage{parent_id: parent_id} = comment_reply <- Context.get(RoomMessage, id),
         false <- is_nil(parent_id),
         {:ok, %RoomMessage{} = comment_reply} <- Context.update(RoomMessage, comment_reply, params) do
      render(
        conn,
        "comment_reply.json",
        %{comment_reply: RoomMessages.preload_all(comment_reply), current_user_id: current_user_id}
      )
    else
      nil -> render(conn, "comment_reply.json", %{error: ["RoomMessage Reply not found"]})
      true -> render(conn, "comment_reply.json", %{error: ["Parent RoomMessage not found."]})
      {:error, error} -> render(conn, "comment_reply.json", %{error: error})
      _ -> render(conn, "comment_reply.json", %{error: "Something went wrong"})
    end
  end

#  def delete(conn, %{"id" => id} = _params) do
#    with %RoomMessage{} = comment_reply <- Context.get(RoomMessage, id),
#         {:ok, %RoomMessage{} = comment_reply} <- Context.delete(comment_reply) do
#      render(conn, "comment_reply.json", %{comment_reply: RoomMessages.preload_all(comment_reply)})
#    else
#      nil -> render(conn, "comment_reply.json", %{error: ["RoomMessage Reply not found"]})
#      {:error, error} -> render(conn, "comment_reply.json", %{error: error})
#      _ -> render(conn, "comment_reply.json", %{error: "Something went wrong"})
#    end
#  end

  #####################################################
  ############## Swagger Implementation ###############
  #####################################################

#  swagger_path :index do
#    get "/v1.0/comments/{parent_sref}/replies"
#    summary "Get List Of RoomMessage Replies"
#    description "Get List OF RoomMessage Replies"
#    produces "application/json"
#    security [%{Bearer: []}]
#    parameters do
#      parent_sref :path, :string, "Parent RoomMessage ID", required: true
#      page(:query, :integer, "Page", required: true)
#    end
#    response 200, "Ok", Schema.ref(:ListReplies)
#  end
#
#  swagger_path :guest_index do
#    get "/v1.0/guest/comments/{parent_sref}/replies"
#    summary "Get List Of RoomMessage Replies for guest"
#    description "Get List OF RoomMessage Replies for guest"
#    produces "application/json"
#    parameters do
#      parent_sref :path, :string, "Parent RoomMessage ID", required: true
#      page(:query, :integer, "Page", required: true)
#    end
#    response 200, "Ok", Schema.ref(:ListReplies)
#  end
#
#  swagger_path :show do
#    get "/v1.0/comments/{parent_sref}/replies/{id}"
#    summary "Get Reply By"
#    description "Get Reply By"
#    produces "application/json"
#    security [%{Bearer: []}]
#    parameters do
#      id :path, :string, "RoomMessage ID", required: true
#    end
#    response 200, "Ok", Schema.ref(:Reply)
#  end
#
#  swagger_path :create do
#    post "/v1.0/comments/{parent_sref}/replies"
#    summary "Create Reply"
#    description "Create Reply by giving the ID of the post and write your comment in the body"
#    produces "application/json"
#    security [%{Bearer: []}]
#    parameters do
#      parent_sref :path, :string, "Parent RoomMessage ID", required: true
#      body :body, Schema.ref(:CreateComment), "Create Reply params", required: true
#    end
#    response 200, "Ok", Schema.ref(:Reply)
#  end
#
#  swagger_path :update do
#    put "/v1.0/comments/{parent_sref}/replies/{id}"
#    summary "Update Reply"
#    description "Update Reply by giving the ID of the post and write your comment in the body"
#    produces "application/json"
#    security [%{Bearer: []}]
#    parameters do
#      id :path, :string, "RoomMessage ID", required: true
#      body :body, Schema.ref(:UpdateComment), "Update Reply Params", required: true
#    end
#    response 200, "Ok", Schema.ref(:Reply)
#  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/comments/{parent_sref}/replies/{id}"
    summary "Delete Reply"
    description "Delete Reply"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "RoomMessage ID", required: true
    end
    response 200, "Ok", Schema.ref(:Reply)
  end
  @doc """
  delete post comment reply.
  """
  def delete(conn, %{"id" => id} = _params) do
    with %RoomMessage{} = comment_reply <- Context.get(RoomMessage, id),
         {:ok, %RoomMessage{} = comment_reply} <- Context.delete(comment_reply) do
      render(conn, "comment_reply.json", %{comment_reply: RoomMessages.preload_all(comment_reply)})
    else
      nil -> render(conn, "comment_reply.json", %{error: ["RoomMessage Reply not found"]})
      {:error, error} -> render(conn, "comment_reply.json", %{error: error})
      _ -> render(conn, "comment_reply.json", %{error: "Something went wrong"})
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
      Reply:
        swagger_schema do
          title("RoomMessage Reply")
          description("Reply to a RoomMessage on a Post")

          example(%{
            responseData: %{
              id: "",
              comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              inserted_at: "",
              updated_at: "",
              description: "Thanks a lot!",
              message_images: [
                "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
              base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
              user: %{
                userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                first_name: "First Name",
                last_name: "Last Name",
                user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                base_url: "https://d1exz3ac7m20xz.cloudfront.net/"
              }
            }
          })
        end,
      ListReplies:
        swagger_schema do
          title("Replies list")
          description("List of all Replies to a specific RoomMessage")

          example(%{
            responseData: %{
              pagination: %{
                total_pages: 2,
                page: 1,
                total_rows: 10
              },
              data: [
                %{
                  id: "",
                  comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                  inserted_at: "",
                  updated_at: "",
                  description: "Thanks a lot!",
                  user: %{
                    userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                    first_name: "First Name",
                    last_name: "Last Name",
                    user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                    base_url: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                },
                %{
                  id: "",
                  comment_id: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                  inserted_at: "",
                  updated_at: "",
                  description: "Thanks a lot!",
                  message_images: [
                          "room_message/e5eeaab6-88da-49fd-a741-7d0c1c50587a.jpg",
                          "room_message/bff176b6-1508-4486-b943-409e67314ac5.jpg" ],
                  base_url: "https://d1exz3ac7m20xz.cloudfront.net/",
                  user: %{
                    userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
                    first_name: "First Name",
                    last_name: "Last Name",
                    user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png",
                    base_url: "https://d1exz3ac7m20xz.cloudfront.net/"
                  }
                },
              ]
            }
          })
        end
    }
  end
end
