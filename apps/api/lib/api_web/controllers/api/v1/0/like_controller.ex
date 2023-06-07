#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.LikeController do
  @moduledoc """
  Manage post/comment/reply likes.
  @todo hook into vnext like engine.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.{UserEventLikes, UserEventsCommentsLikes}
  alias Data.Schema.{UserEventLike, UserEvent, UserEventCommentLike, RoomMessage, RoomMessageMeta}
  alias ApiWeb.Utils.Common

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # like_post/2
  #----------------------------------------------------------------------------
  swagger_path :like_post do
    post("/v1.0/like")
    summary("Create/Delete Post Like")
    description("Create/Delete Post Like by adding item_id and item_type in the params")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:LikePost), "like post from params", required: true)
    end

    response(200, "Ok", Schema.ref(:UserEventLike))
  end
  @doc """
  Mark post as liked.
  """
  def like_post(conn, %{"liked" => liked, "item_id" => item_id} = params) do
    %{id: user_id, first_name: first_name, last_name: last_name} = _user = Api.Guardian.Plug.current_resource(conn)
#    _push_notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
#      "event" => "feed_post_like", "device_token" => params["device_token"]}
    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b32"
    case Context.get(UserEvent, item_id) do
      %UserEvent{} = post ->
        case UserEventLikes.get_like_by_post_and_user_id(item_id, user_id) do
          nil ->
            if liked == true do
              Context.create(UserEventLike, %{
                liked: liked,
                item_id: item_id,
                user_id: user_id
              })
              Jetzy.Module.Telemetry.Analytics.post_favorite(conn, user_id, item_id)
              likes_count = UserEventLikes.get_likes_count_by_item_id(post.id)
              payload = %{
                "post" => %{
                  "id" => post.id,
                },
                "likesCount" => likes_count
              }

              ApiWeb.Endpoint.broadcast("event_comments:#{post.room_id}", "post_liked", payload)
              Common.broadcast_for_like("user_profile:#{post.user_id}", post, likes_count)
              Common.broadcast_for_like("jetzy_timeline", post, likes_count)
              ApiWeb.Utils.Common.update_points(post.user_id, :post_liked)
              %{} = user = Data.Context.UserEvents.get_user_by_event_id(params["item_id"])
              if user_id != user.id do
                push_notification_params = %{
                  "keys" => %{
                    "first_name" => first_name,
                    "last_name" => last_name
                  },
                  "event" => "feed_post_like",
                  "user_id" => user.id,
                  "sender_id" => user_id,
                  "type" => "feed_post_like",
                  "resource_id" => item_id
                }
                ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
              end
            end

          like_details ->
            if liked == false do
              Context.delete(like_details)
              likes_count = UserEventLikes.get_likes_count_by_item_id(post.id)
              payload = %{
                "post" => %{
                  "id" => post.id,
                },
                "likesCount" => likes_count
              }

              ApiWeb.Endpoint.broadcast("event_comments:#{post.room_id}", "post_liked", payload)
              Common.broadcast_for_like("user_profile:#{post.user_id}", post, likes_count)
              Common.broadcast_for_like("jetzy_timeline", post, likes_count)
            end
        end

        render(conn, "like_detail.json", params)

      nil ->
        render(conn, "like_detail.json", %{error: "Post doesn't exist"})
    end
  end

  #----------------------------------------------------------------------------
  # like_unlike_comment_or_reply/2
  #----------------------------------------------------------------------------
  swagger_path :like_unlike_comment_or_reply do
    post "/v1.0/user-event-likes"
    summary "Like or Unlike a Comment or Reply"
    description "Like or Unlike a Comment or a Reply by ID of the comment or reply"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:LikeComment), "Like a Comment or Reply", required: true
    end
    response 200, "Ok", Schema.ref(:UserEventCommentLike)
  end

  @doc """
  Toggle comment/reply like flag.
  """
  def like_unlike_comment_or_reply(conn, %{"comment_id" => room_message_id, "is_liked"=> true} = params) do
    %{id: user_id, first_name: first_name, last_name: last_name} = _user = Api.Guardian.Plug.current_resource(conn)
    with %RoomMessage{} = room_message <- Context.get(RoomMessage, room_message_id),
         nil <- UserEventsCommentsLikes.get_like_by_comment_and_user_id(room_message_id, user_id),
         {:ok, %UserEventCommentLike{} = _like} = Context.create(UserEventCommentLike, %{liked: true,
           room_message_id: room_message_id, liked_by_id: user_id}) do
      Jetzy.Module.Telemetry.Analytics.comment_favorite(conn, user_id, room_message_id)
      increase_likes(conn, room_message)
      %{sender_id: receiver_id} = room_message
      if user_id != receiver_id do
        case room_message do
          %{sender_id: receiver_id, parent_id: nil  } = room_message ->
              push_notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
                "event" => "post_comment_like", "user_id" => receiver_id, "sender_id" => user_id, "type" => "post_comment_like", "resource_id" => UserEventsCommentsLikes.get_user_event_by_room_message_id(room_message_id)}
              ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
          %{sender_id: receiver_id, parent_id: parent_id} = room_message ->
              push_notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
                "event" => "post_comment_reply_like", "user_id" => receiver_id, "sender_id" => user_id, "type" => "post_comment_reply_like", "resource_id" => UserEventsCommentsLikes.get_user_event_by_room_message_id(room_message_id)}
              ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
        end
      end
    else
      %UserEventCommentLike{} -> render(conn, "like_detail.json", %{error: "Already Liked"})
      nil -> render(conn, "like_detail.json", %{error: "Room Message Not Found"})
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "like_detail.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      {:error, error} -> render(conn, "like_detail.json", %{error: error})
      _ -> render(conn, "like_detail.json", %{error: "Something went wrong"})
    end
  end

  def like_unlike_comment_or_reply(conn, %{"comment_id" => room_message_id, "is_liked"=> false} = _params) do
    %{id: user_id} = _user = Api.Guardian.Plug.current_resource(conn)
    with %RoomMessage{} = room_message <- Context.get(RoomMessage, room_message_id),
         %UserEventCommentLike{} = like <- UserEventsCommentsLikes.get_like_by_comment_and_user_id(
           room_message_id, user_id),
         {:ok, _data} <- Context.delete(like) do
        decrease_likes(conn, room_message)
      else
        nil -> render(conn, "like_detail.json", %{error: "Record Not Found"})
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "like_detail.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        {:error, error} -> render(conn, "like_detail.json", %{error: error})
        _ -> render(conn, "like_detail.json", %{error: "Something went wrong"})
    end
  end
  def like_unlike_comment_or_reply(conn, _) do
    render(conn, "like_detail.json", %{error: "Invalid Params"})
  end

  # @todo delete after may 2022
  #  swagger_path :like_comment do
  #    post("/v1.0/shoutout-comment-like")
  #    summary("Create Comment Like")
  #    description("Create Comment Like by adding comment_id and is_liked in the params")
  #    produces("application/json")
  #    security([%{Bearer: []}])
  #
  #    parameters do
  #      body(:body, Schema.ref(:LikeComment), "like Comment from params", required: true)
  #    end
  #
  #    response(200, "Ok", Schema.ref(:UserEventLike))
  #  end
  #  def like_comment(conn, %{"is_liked" => is_liked, "comment_id" => comment_id} = params) do
  #    %{id: user_id, first_name: first_name} = user = Api.Guardian.Plug.current_resource(conn)
  #
  #    case Context.get(Comment, comment_id) do
  #      %Comment{} = comment ->
  #        case ShoutCommentLikes.get_like_by_comment_and_user_id(comment_id, user_id)  do
  #          nil ->
  #            if is_liked == true do
  #              Context.create(ShoutCommentLike, %{
  #                is_liked: is_liked,
  #                comment_id: comment_id,
  #                user_id: user_id,
  #
  #              })
  #            end
  #          shoutout_comment_like ->
  #            if is_liked == false do
  #              Context.delete(shoutout_comment_like)
  #            end
  #        end
  #
  #        render(conn, "like_comment.json", Map.merge(params, %{"current_user_id" => user_id}))
  #
  #      nil ->
  #        render(conn, "like_detail.json", %{error: "Comment doesn't exist"})
  #    end
  #  end


  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # increase_likes/2
  #----------------------------------------------------------------------------
#  @doc """
#  @todo actual logic should be moved in a domain object  with render line stripped for testability and reusability.
#  """
  defp increase_likes(conn, message) do
    case Context.get_by(RoomMessageMeta, [room_message_id: message.id]) do
      %{no_of_likes: likes} = meta ->
        {:ok, rmm} = Context.update(RoomMessageMeta, meta, %{no_of_likes: likes + 1})
        payload = %{
          "comment" => %{
            "id" => message.id,
          },
          "likesCount" => rmm.no_of_likes
        }
        ApiWeb.Endpoint.broadcast("event_comments:#{message.room_id}", "comment_liked", payload)
      nil ->
    {:ok, rmm} = Context.create(RoomMessageMeta, %{no_of_likes: 1, room_message_id: message.id,
          user_id: message.sender_id, room_id: message.room_id})
    payload = %{
      "comment" => %{
        "parentId" => message.parent_id,
        "id" => message.id,
      },
      "likesCount" => rmm.no_of_likes
    }
    ApiWeb.Endpoint.broadcast("event_comments:#{message.room_id}", "comment_liked", payload)
    end
    render(conn, "comment_like.json", %{room_message: message})
  end

  #----------------------------------------------------------------------------
  # decrease_likes/2
  #----------------------------------------------------------------------------
#  @doc """
#  @todo actual logic should be moved in a domain object  with render line stripped for testability and reusability.
#  """
  defp decrease_likes(conn, message) do
    case Context.get_by(RoomMessageMeta, [room_message_id: message.id]) do
      %{no_of_likes: likes} = meta ->
      {:ok, rmm} = Context.update(RoomMessageMeta, meta, %{no_of_likes: likes - 1})
      payload = %{
        "comment" => %{
          "id" => message.id,
        },
        "likesCount" => rmm.no_of_likes
      }
      ApiWeb.Endpoint.broadcast("event_comments:#{message.room_id}", "comment_liked", payload)
      render(conn, "comment_like.json", %{room_message: message})
      _ -> render(conn, "like_detail.json", %{error: "Something Went Wrong"})
    end
  end


  #----------------------------------------------------------------------------
  # list_likes/2
  #----------------------------------------------------------------------------
  swagger_path :list_likes do
      get "/v1.0/list-likes"
      summary "See who liked the post or comment"
      description "See the list of people who liked a post or a comment"
      produces "application/json"
      parameters do
        page(:query, :integer, "Page no.", required: true)
        post_id(:query, :string, "Post (Event) ID")
        comment_id(:query, :string, "Comment ID")
        search(:query, :string, "Search")
      end
      response 200, "Ok", Schema.ref(:ListLikes)
    end
  @doc """
  List likers of post.
  """
  def list_likes(conn, %{"post_id" => id} = params) do
    with %{} <- Context.get(UserEvent, id),
    users <- UserEventLikes.list_users_who_liked(params) do
        render(conn, "liked_by.json", %{users: users})
      else
        nil -> render(conn, "like_detail.json", %{error: "No Record Found"})
        _ -> render(conn, "like_detail.json", %{error: "Something Went Wrong"})
    end
  end
  def list_likes(conn, %{"comment_id" => comment_id} = params) do
    with %{} <- Context.get(RoomMessage, comment_id),
         users <- UserEventsCommentsLikes.list_people_who_like(params) do
        render(conn, "liked_by.json", %{users: users})
    else
      nil -> render(conn, "like_detail.json", %{error: "No Record Found"})
      _ -> render(conn, "like_detail.json", %{error: "Something Went Wrong"})
    end
  end
  def list_likes(conn, _) do
    render(conn, "like_detail.json", %{error: "Invalid Params"})
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      LikePost:
        swagger_schema do
          title("Like Post")
          description("Like Post")

          properties do
            liked(:boolean, "Liked i.e true or false")
            item_id(:string, "Item(post) id")
          end

          example(%{
            liked: true,
            item_id: "db384dee-a527-4933-87ba-d090c142e922"
          })
        end,
      UserEventLike:
        swagger_schema do
          title("UserEvent Likes")
          description("UserEvent Like details")

          example(%{
            ResponseData: %{
              is_deleted: false,
              item_id: "",
              item_type: "",
              status: true,
              total_likes: 2,
              user_self_like: true
            }
          })
        end,


      LikeComment:
        swagger_schema do
          title("Like Comment")
          description("Like Comment")

          properties do
            is_liked(:boolean, "Liked i.e true or false")
            comment_id(:string, "Comment id")
          end

          example(%{
            is_liked: true,
            comment_id: "db384dee-a527-4933-87ba-d090c142e922"
          })
        end,
      UserEventCommentLike:
        swagger_schema do
          title("Like Or Unlike a Comment")
          description("Like or Unlike a Comment")

          properties do
            message(:string, "Comment Liked or Unliked")
          end

          example(%{
            message: "Comment Liked!"
          })
        end,
      ListLikes:
        swagger_schema do
          title("List Likes")
          description("See people who liked the post or comment")
          example([
            %{
              userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              first_name: "First name",
              last_name: "Last name",
              user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
            },
            %{
              userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              first_name: "First name",
              last_name: "Last name",
              user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
            }
          ])
        end
    }
  end
end
