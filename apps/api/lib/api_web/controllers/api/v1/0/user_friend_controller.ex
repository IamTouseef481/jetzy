#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserFriendController do
  @moduledoc """
  Create Friend Requests and List user friends.
  @todo some of this logic exists in other controllers I believe - keith
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.{UserFriends, UserBlocks}
  alias Data.Schema.{User, UserFriend}

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/friend"
    summary "Create Friend Request"
    description "Create Friend Request by friend id"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreateFriend), "Create Friend params", required: true
    end
    response 200, "Ok", Schema.ref(:Friend)
  end

  @doc """
  Create a friend request.
  """
  def create(conn, %{"friend_id" => friend_id} = params) do
    %{id: user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)
    params = Map.merge(params, %{"user_id" => user_id})

    with true <- friend_id not in blocked_user_ids,
         %User{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} = friend <- Context.get(User, friend_id),
         false <- is_deleted or is_deactivated or is_self_deactivated,
         nil <- UserFriends.check_friend_request_exist(user_id, friend_id),
      {:ok, user_friend} <- Context.create(UserFriend, params) do
      push_notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
        "event" => "user_friend_request", "user_id" => friend.id,
        "template_name" => "notification_email.html",
        "sender_id" => user_id,
        "type" => "user_friend_request",
        "resource_id" => friend.id,
        "subject" => "Friend Request"
      }
      ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
      ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: friend.email}, push_notification_params)
      render(conn, "user_friend.json", %{user_friend: user_friend,
        friend: Context.preload_selective(friend, :interests)})
#          user_friend -> Context.update(UserFriend, user_friend, params)
      else
        false -> render(conn, "user_friend.json", %{error: "The requested user is blocked by you."})
        nil -> render(conn, "user_friend.json", %{error: "User friend not found"})
        true -> render(conn, "user_friend.json", %{error: "User either deactivated or deleted"})
        %UserFriend{} -> render(conn, "user_friend.json", %{error: "User friend already exists"})
        {:error, changeset} -> render(conn, "user_friend.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        _ -> render(conn, "user_friend.json", %{error: "Something went wrong."})
#    %{id: user_id, first_name: first_name} = Api.Guardian.Plug.current_resource(conn)
#    with %User{} = _sender <- Context.get(User, user_id),
#         %User{} = friend <- Context.get(User, friend_id) do
#      params = Map.merge(params, %{"user_id" => user_id})
#      {:ok, user_friend} =
#        case UserFriends.check_friend_request_exist(user_id, friend_id) do
#          nil -> Context.create(UserFriend, params)
#          user_friend -> Context.update(UserFriend, user_friend, params)
#        end
#      push_notification_params = %{"keys" => %{"first_name" => first_name},
#        "event" => "user_friend_request", "user_id" => friend.id,
#        "template_name" => "notification_email.html",
#        "sender_id" => user_id
#      }
#      ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
#      ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: friend.email}, push_notification_params)
#      render(conn, "user_friend.json", %{
#        user_friend: user_friend,
#        friend: Context.preload_selective(friend, :interests)
#      })
#    else
#      nil -> render(conn, "user_friend.json", %{error: ["User friend not found"]})
#      {:error, error} -> render(conn, "user_friend.json", %{error: error})
#    end
  end
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/friend/{id}"
    summary "Get Friends By user ID"
    description "Get a user's Friend list By his/her ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "user ID", required: true
    end
    response 200, "Ok", Schema.ref(:Friends)
  end

  @doc """
  Get user friends by id.
  """
  def show(conn, %{"id" => id}) do
    user_friends = Context.UserFriends.get_friends_by_user_id(id)
    render(conn, "user_friends.json", %{user_friends: user_friends})
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      Friend: swagger_schema do
        title "Friend"
        description "Friend"
        example %{
          id: "3a3a53d-1d55-40c2-b955-57f8d7be0232",
          is_friend: true,
          is_request_sent: true,
          is_blocked: false,
          friend_blocked: false,
          user_id: "3a3a53d-1d55-40c2-b955-57f8d7be0233",
        }
      end,
      Friends: swagger_schema do
        title "Friends"
        description "List of Friends"
        example [
          %{
            id: "3a3a53d-1d55-40c2-b955-57f8d7be0232",
            is_friend: true,
            is_request_sent: true,
            is_blocked: false,
            friend_blocked: false,
            created_date: "2021-11-07",
            user_id: "3a3a53d-1d55-40c2-b955-57f8d7be0233",
          },
          %{
            id: "3a3a53d-1d55-40c2-b955-57f8d7be0232",
            is_friend: true,
            is_request_sent: true,
            is_blocked: false,
            friend_blocked: false,
            created_date: "2021-11-07",
            user_id: "3a3a53d-1d55-40c2-b955-57f8d7be0233",
          }
        ]
      end,
      CreateFriend: swagger_schema do
        title "Create Friend"
        description "Create Friend"
        properties do
          friend_id :string, "Friend ID"
        end
        example %{
          friend_id: "3a3a53d-1d55-40c2-b955-57f8d7be0232"
        }
      end
    }
  end
end
