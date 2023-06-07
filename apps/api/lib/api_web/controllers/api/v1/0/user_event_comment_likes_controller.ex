#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserEventCommentLikesController do
  @moduledoc """
  Manage User Event likes.
  @todo is this module deprecated? - kebrings
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.UserEventsCommentsLikes
  alias Data.Schema.{UserEventCommentLike, RoomMessageMeta, RoomMessage}

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # like_comment_or_reply/2
  #----------------------------------------------------------------------------
  # @TODO update or remove by may 2022
  #  swagger_path :like_comment_or_reply do
  #    post "/v1.0/user-event-likes"
  #    summary "Like or Unlike a Comment or Reply"
  #    description "Like or Unlike a Comment or a Reply by ID of the comment or reply"
  #    produces "application/json"
  #    security [%{Bearer: []}]
  #    parameters do
  #      body :body, Schema.ref(:LikeComment), "Like a Comment or Reply", required: true
  #    end
  #    response 200, "Ok", Schema.ref( :UserEventCommentLike )
  #  end
  @doc """
  Like or Unlike a Comment or a Reply by ID of the comment or reply
  """
  def like_comment_or_reply(conn, %{"comment_id" => room_message_id, "is_liked"=> liked} = params) do
    %{id: user_id, first_name: first_name} = _user = Api.Guardian.Plug.current_resource(conn)
    _push_notification_params = %{"keys" => %{"first_name" => first_name},
      "event" => "feed_post_like", "device_token" => params["device_token"]}
    case Context.get(RoomMessage, room_message_id) do
      %RoomMessage{} = post ->

        case UserEventsCommentsLikes.get_like_by_comment_and_user_id(room_message_id, user_id) do
          nil ->
            if liked == true do
             {:ok, %Data.Schema.UserEventCommentLike{} = saved} = Context.create(UserEventCommentLike, %{
                liked: liked,
                room_message_id: room_message_id,
                liked_by_id: user_id
              })
             case Context.get_by(RoomMessageMeta, [room_message_id: room_message_id]) do
               %{no_of_likes: likes} = meta ->
                 Context.update(RoomMessageMeta, meta, %{no_of_likes: likes + 1})
               nil ->
                 Context.create(RoomMessageMeta, %{no_of_likes: 1, room_message_id: room_message_id, user_id: post.sender_id, room_id: post.room_id})
             end

             render(conn, "room_message_like.json",
                %{"room_message_id"=> room_message_id, "liked_by_id"=> user_id, "id" => saved.id})
            end

          like_details ->
            if liked == false do
              case Context.get_by(RoomMessageMeta, [room_message_id: room_message_id]) do
                %{no_of_likes: likes} = meta ->
                  Context.update(RoomMessageMeta, meta, %{no_of_likes: max(likes - 1, 0)})
                nil ->
                  Context.create(RoomMessageMeta, %{no_of_likes: 0, room_message_id: room_message_id, user_id: post.sender_id, room_id: post.room_id})
              end
              Context.delete(like_details)
            end
            render(conn, "room_message_like.json",
              %{"room_message_id"=> room_message_id, "liked_by_id"=> user_id, "id" => like_details.id})
        end

      nil ->
        render(conn, "room_message_like.json", %{error: "Post doesn't exist"})
    end
  end

  #----------------------------------------------------------------------------
  # unlike_comment_or_reply/2
  #----------------------------------------------------------------------------
  # @TODO update or remove by may 2022
  #  swagger_path :unlike_comment_or_reply do
  #    delete "/v1.0/user-event-likes"
  #    summary "Unlike a Comment or Reply"
  #    description "Unlike a Comment or a Reply by ID of the comment or reply"
  #    produces "application/json"
  #    security [%{Bearer: []}]
  #    parameters do
  #      body :body, Schema.ref(:UnlikeComment), "UnLike a Comment or Reply", required: true
  #    end
  #    response 200, "Ok", Schema.ref(:UserEventCommentLike)
  #  end
  @doc """
  Unlike a Comment or a Reply by ID of the comment or reply
  """
  def unlike_comment_or_reply(conn, %{"room_message_id" => room_message_id}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %UserEventCommentLike{} = record <- Context.get_by(UserEventCommentLike, [room_message_id: room_message_id, liked_by_id: user_id]),
         %{no_of_likes: likes} = meta <- Context.get_by(RoomMessageMeta, [room_message_id: room_message_id]),
         {:ok, like} <- Context.delete(record) do
      Context.update(RoomMessageMeta, meta, %{no_of_likes: likes - 1})
      render(conn, "like.json", %{like: like})
      else
        nil -> render(conn, "message.json", %{message: "Not Found"})
       {:error, error} -> render(conn, "error.json", %{error: error})
       _ -> render(conn, "error.json", %{error: "Something went wrong"})
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
    LikeComment: swagger_schema do
      title "Like a Comment or Reply"
      description "Like a Comment or Reply"
      properties do
        room_message_id :string, "Room Message ID"
      end
      example %{
        room_message_id: "Room Message ID"
      }
    end,
    UnlikeComment: swagger_schema do
      title "Unlike a Comment or Reply that a user previously liked"
      description "Unlike a Comment or Reply that a user previously liked"
      properties do
        room_message_id :string, "Room Message ID"
      end
      example %{
        room_message_id: "Room Message ID"
      }
    end,
    UserEventCommentLike: swagger_schema do
      title "Response to user Like/Unlike"
      description "Response to user Like/Unlike"
      properties do
        id :string, "Record ID"
        room_message_id :string, "Room Message ID"
        liked_by_id :string, "User ID"
      end
      example %{
        id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
        room_message_id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
        liked_by_id: "03bf0706-b7e9-33b8-aee5-c6142a816478"
      }
    end
  }
  end

end
