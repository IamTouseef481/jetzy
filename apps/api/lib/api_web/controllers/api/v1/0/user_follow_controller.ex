#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserFollowController do
  @moduledoc """
  Manage user follower relationships.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Repo
  alias Data.Context
  alias Data.Context.{UserFollows,
#                      UserBlocks
    }
  alias Data.Schema.{User, UserFollow, UserSetting, NotificationsRecord}

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/follow"
    summary "Follow or Unfollow a User. Or cancel a follow request"
    description "Follow or Unfollow a User. Or cancel a follow request"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      status_id :query,  :array, "Follow, Unfollow or Cancel follow request", required: true,
                items: [type: :string, enum: ["followed", "unfollowed", "cancelled"]]
#      body :body, Schema.ref( :CreateFollow ), "Create Follow params", required: true
      followed_id(:query, :string, "User ID to follow or unfollow", required: true)
    end
    response 200, "Ok", Schema.ref(:Follow)
  end

  @doc """
  Follow or Unfollow a user.
  @todo bade RESTFul naming.
  """
  def create(conn, %{"followed_id" => followed_id, "status_id" => "unfollowed"} = params) do
    %{id: current_user_id, first_name: _first_name} = Api.Guardian.Plug.current_resource(conn)
    _params = Map.merge(params, %{"follower_id" => current_user_id})
    with %User{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} = _follow <- Context.get(User, followed_id),
         false <- is_deleted or is_deactivated or is_self_deactivated,
         nil <- UserFollows.check_follow_request_exist(followed_id, current_user_id) do
          render(conn, "user_follow.json", %{error: "You are not following that person currently"})
    else
      true ->
        render(conn, "user_follow.json", %{error: "User either deactivated or deleted"})
      %UserFollow{follow_status: :followed} = user ->
        case Context.update(UserFollow, user, %{follow_status: "unfollowed"}) do
          {:ok, %UserFollow{follow_status: :unfollowed} = follow} ->
            Jetzy.Module.Telemetry.Analytics.user_unfollow(conn, current_user_id, follow)
            ApiWeb.Utils.PushNotification.soft_delete_push_notification(current_user_id, followed_id, ["follow_request", "follow"])
            render(conn, "user_follow.json", %{message: "You have unfollowed the User"})
          {:error, changeset} ->
            render(conn, "user_follow.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        end
      %UserFollow{follow_status: :unfollowed} ->
        render(conn, "user_follow.json", %{error: "You already unfollowed the user"})
      %UserFollow{follow_status: :requested} -> render(conn, "user_follow.json", %{message: "Your follow request is still pending"})
      {:error, changeset} ->
        render(conn, "user_follow.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      _ ->
        render(conn, "user_follow.json", %{error: "Something went wrong."})
    end
  end

  def create(conn, %{"followed_id" => followed_id, "status_id" => "cancelled"} = _params) do
    %{id: follower_id, first_name: _first_name}  = Api.Guardian.Plug.current_resource(conn)
    # params = Map.merge(params, %{"follower_id" => follower_id})

    with %{} = _user <- Context.get(User, followed_id),
         %{follow_status: :requested} = userfollow <- Context.get_by(UserFollow, [followed_id: followed_id, follower_id: follower_id]),
         {:ok, follow} <- Context.update(UserFollow, userfollow, %{follow_status: :cancelled}) do
          Jetzy.Module.Telemetry.Analytics.user_unfollow(conn, follower_id, follow)
          ApiWeb.Utils.PushNotification.soft_delete_push_notification(follower_id, followed_id, ["follow_request", "follow"])
          render(conn, "user_follow.json", %{message: "Your follow request is cancelled successfully"})
      else
        nil -> render(conn, "user_follow.json", %{error: "User not found"})
        %UserFollow{} -> render(conn, "user_follow.json", %{error: "No follow request found"})
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "user_follow.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        {:error, error} ->
          render(conn, "user_follow.json", %{error: error})
        _ -> render(conn, "user_follow.json", %{error: "Something went wrong."})
    end
  end

  def create(conn, %{"followed_id" => followed_id, "status_id" => _status_id} = params) do
    # Get current user id as a follower_id
    %{id: follower_id, first_name: first_name, last_name: last_name, shareable_link: shareable_link}  = Api.Guardian.Plug.current_resource(conn)
    # update params to add follower_id
    params = Map.merge(params, %{"follower_id" => follower_id})

    # Get followed user record to check deleted or deactivated account or account exist
    case Context.get(User, followed_id) do
      %User{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} = follow ->
        # Set notifications params for user follow
        params_for_user_settings = %{
          "followed_id" => followed_id,
          "follower_id" => follower_id,
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => follow.email,
          "params" => params,
          "shareable_link" => shareable_link
        }

        with true <- follower_id != followed_id,
             false <- is_deleted or is_deactivated or is_self_deactivated,
             nil <- UserFollows.check_follow_request_exist(followed_id, follower_id) do
              check_user_settings(conn, params_for_user_settings)
          else
            false -> render(conn, "user_follow.json", %{error: "Followed ID cannot be the same as user ID"})
            true ->
              render(conn, "user_follow.json", %{error: "User either deactivated or deleted"})
            %UserFollow{follow_status: :followed} ->
              render(conn, "user_follow.json", %{message: "You already followed this account"})
            %UserFollow{follow_status: :requested} = follow ->
              Jetzy.Module.Telemetry.Analytics.user_follow(conn, follower_id, follow)
              render(conn, "user_follow.json", %{message: "You already have sent a follow request"})
            %UserFollow{follow_status: status_id} = existing_record when status_id in [:unfollowed, :cancelled] ->
              check_user_settings(conn, Map.put(params_for_user_settings, "existing_record", existing_record))
            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "user_follow.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
            {:error, error} ->
              render(conn, "user_follow.json", %{error: error})
            _ ->
              render(conn, "user_follow.json", %{error: "Something went wrong."})
        end
        nil -> render(conn, "user_follow.json", %{error: "User not Found"})
      end
  end

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/follow"
    summary "Get a List of following or follower"
    description "Get a List of following or follower."
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      followed_id :query, :string, "List of Followers by User ID"
      follower_id :query, :string, "List of Following by user ID"
      page(:query, :integer, "Page", required: true)
    end
    response 200, "Ok", Schema.ref(:GetFollow)
  end

  @doc """
  Get list of followings and followers
  @todo I used this frienda/friendb schema in the past at cartoondollemporium when it was still a large social networking website. It caused a lot of problems with query optimization.
  """
  def index(conn, %{"followed_id" => followed_id, "page" => page}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    if current_user_id == followed_id do
      data = UserFollows.get_follower_by_followed_id_of_current_user(followed_id, page)
      render(conn, "user_follows.json", user_follows: data, current_user_id: current_user_id)
      else
      data = UserFollows.get_follower_by_followed_id_of_other_user(followed_id, page)
      render(conn, "user_follows.json", %{user_follows: data, current_user_id: current_user_id})
    end
  end
  def index(conn, %{"follower_id" => follower_id, "page" => page}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    if current_user_id == follower_id do
    data = UserFollows.get_followed_by_follower_id_of_current_user(follower_id, page)
      render(conn, "user_follows.json", %{user_follows: data, current_user_id: current_user_id})
    else
      data = UserFollows.get_followed_by_follower_id_of_other_user(follower_id, page)
      render(conn, "user_follows.json", user_follows: data, current_user_id: current_user_id)
    end
  end
  def index(conn, _params) do
    render(conn, "user_follow.json", %{message: "Invalid Params"})
  end

  # @todo delete or implement by may 2022
  # #----------------------------------------------------------------------------
  # # show/2
  # #----------------------------------------------------------------------------
  #  def show(conn, %{"id" => id}) do
  #    user_friends = Context.UserFollows.get_follows_by_user_id(id)
  #    render(conn, "user_friends.json", %{user_friends: user_friends})
  #  end

  #----------------------------------------------------------------------------
  # accept_or_decline_follow_request/2
  #----------------------------------------------------------------------------
  swagger_path :accept_or_decline_follow_request do
    post "/v1.0/accept-decline-request"
    summary "Accept or Decline Follow Request"
    description "Accept or Decline Follow Request"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      status_id :query,  :array, "Accept or Decline request", required: true,
                                                              items: [type: :string, enum: ["followed", "unfollowed"]]
      #      body :body, Schema.ref( :AcceptDeclineFollow ), "Create Follow params", required: true
      user_id(:query, :string, "User ID whose request is to be Accepted or declined", required: true)
    end
    response 200, "Ok", Schema.ref(:Follows)
  end

  @doc """
  Accept or decline a follow request.
  """
  def accept_or_decline_follow_request(conn, %{"status_id" => status_id, "user_id" => follower_id} = _params)do
    %{id: current_user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)

    follower = Context.get(User, follower_id)
    name = follower.first_name || "" <> follower.last_name || ""

    # ApiWeb.Utils.PushNotification.soft_delete_push_notification(current_user_id, follower_id, ["follow_request", "follow"])

    case status_id do
      "unfollowed"->
        ApiWeb.Utils.PushNotification.soft_delete_push_notification(follower_id, current_user_id, ["follow_request", "follow"])
        :ok
      "followed" -> update_notification_for_accepted(current_user_id, follower_id, name)
      _ -> :ok
    end

    with %{} = user_follow <- UserFollows.get_user_by_followed_or_follower_id_and_follow_status(current_user_id, follower_id),
         {:ok, %UserFollow{follow_status: :followed}} <- Context.update(UserFollow, user_follow, %{follow_status: status_id}) do

          notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
            "user_id" => follower_id,
            "template_name" => "notification_email.html",
            "event" => "accept_follow",
            "sender_id" => current_user_id,
            "type" => "user_follow",
            "resource_id" => follower_id,
            "subject" => "#{first_name} accepted your follow request"
          }

          ApiWeb.Utils.PushNotification.send_push_notification(notification_params)
          ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: follower.email}, notification_params)

          render(conn, "user_follow.json", %{message: "Follow request Accepted"})
      else
        nil -> render(conn, "user_follow.json", %{error: "No request found"})
        {:ok, %UserFollow{follow_status: :unfollowed}} ->
            render(conn, "user_follow.json", %{message: "Follow request Rejected"})
        {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "user_follow.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        _ -> render(conn, "user_follow.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # show_current_user_follow_requests_list/2
  #----------------------------------------------------------------------------
  swagger_path :show_current_user_follow_requests_list do
    get "/v1.0/follow-request-list"
    summary "Get Follow Request"
    description "Get Follow Request of Current User"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      page(:query, :integer, "Page", required: true)
    end
    response 200, "Ok", Schema.ref(:Follows)
  end

  @doc """
  Show current user's follow requests.
  """
  def show_current_user_follow_requests_list(conn, %{"page" => page}) do
    %{id: current_id} = Api.Guardian.Plug.current_resource(conn)
    case UserFollows.get_requested_users_by_follower_id(current_id, page) do
      nil -> render(conn, "user_follow.json", %{message: "No Follow Requests"})
      requests_list ->
        entries = UserFollows.preload_all(requests_list.entries)
        render(conn, "user_follows.json", %{user_follows: Map.merge(requests_list, %{entries: entries})})
    end
  end


  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # soft_delete_follow_notification/2
  #----------------------------------------------------------------------------
  defp soft_delete_follow_notification(followed_id, follower_id) do
    NotificationsRecord
    |> where([rmm], rmm.sender_id == ^follower_id)
    |> where([rmm], rmm.receiver_id == ^followed_id)
    |> where([rmm], is_nil(rmm.deleted_at))
    |> where([rmm], rmm.type in ["follow_request", "follow"])
    |> Repo.update_all([set: [is_deleted: true, updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      deleted_at: DateTime.truncate(DateTime.utc_now(), :second)]])
  end

  #----------------------------------------------------------------------------
  # update_notification_for_accepted/3
  #----------------------------------------------------------------------------
  defp update_notification_for_accepted(followed_id, follower_id, full_name) do
    notification_type = Data.Context.NotificationTypes.get_notification_type_by_event("follow")
    msg = String.replace(notification_type.message, "{{full_name}}", full_name)
    NotificationsRecord
    |> where([rmm], rmm.sender_id == ^follower_id)
    |> where([rmm], rmm.receiver_id == ^followed_id)
    |> where([rmm], is_nil(rmm.deleted_at))
    |> where([rmm], rmm.type in ["follow_request"])
    |> Repo.update_all([set: [description: msg, type: "follow", updated_at: DateTime.truncate(DateTime.utc_now(), :second)]])
  end

  #----------------------------------------------------------------------------
  # check_user_settings/2
  #----------------------------------------------------------------------------
  def check_user_settings(conn, %{"followed_id" => followed_id, "follower_id" => follower_id,
    "first_name" => first_name,"last_name" => last_name, "email" => email, "params" => params, "shareable_link" => shareable_link} = settings) do

    push_notification_params = %{"keys" => %{"first_name" => first_name, "last_name" => last_name},
      "user_id" => followed_id, "template_name" => "notification_email.html",
      "sender_id" => follower_id, "type" => "user_follow", "resource_id" => followed_id}

    case Context.get_by(UserSetting, [user_id: followed_id]) do

      # Incase of follow status private
      %UserSetting{is_follow_public: false} ->
        push_notification_params = Map.merge(push_notification_params, %{"event" => "follow_request", "subject" => "#{first_name} requested to follow you"})
        create_follow(conn, Map.merge(settings, %{"follow_status" => "requested",
          "notification_params" => push_notification_params, "email" => email}))

      # Incase of follow status public
      %UserSetting{is_follow_public: true} ->
        push_notification_params = Map.merge(push_notification_params, %{"event" => "follow", "subject" => "#{first_name} started following you"})
        create_follow(conn, Map.merge(settings, %{"follow_status" => params["status_id"],
          "notification_params" => push_notification_params, "email" => email, "shareable_link" => shareable_link}))
      _ ->
        render(conn, "user_follow.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # create_follow/2
  #----------------------------------------------------------------------------
  defp create_follow(conn, %{"notification_params" => %{"keys" => %{"first_name" => _first_name, "last_name" => _last_name}} = _notification_params, "existing_record" => _existing_record} = params) do
      case  Context.update(UserFollow, params["existing_record"], %{follow_status: params["follow_status"]}) do
        {:ok, result} ->
          params = put_in(params, ["notification_params", "subject"], "#{_first_name} unfollwed you")
          create_follow_render(conn, result, params)
        _ -> render(conn, "user_follow.json", %{error: "Something went wrong"})
      end
  end
  defp  create_follow(conn, %{"notification_params" => %{"keys" => %{"first_name" => _first_name, "last_name" => _last_name}} = _notification_params} = params) do
      case Context.create(UserFollow, params)  do
      {:ok, result} -> create_follow_render(conn, result, params)
      _ -> render(conn, "user_follow.json", %{error: "Something went wrong"})
      end
  end

  #----------------------------------------------------------------------------
  # create_follow_render/3
  #----------------------------------------------------------------------------
  defp create_follow_render(conn, result, params) do
    %{"notification_params" => %{"keys" => %{"first_name" => first_name, "last_name" => last_name}, "user_id" => followed_id, "sender_id" => sender_id} = notification_params} = params
    notification_params = Map.merge(notification_params, %{"shareable_link" => params["shareable_link"]})
    ApiWeb.Utils.PushNotification.soft_delete_push_notification(sender_id, followed_id, ["follow_request", "follow"])

    case result do
    %UserFollow{follow_status: :followed} ->
      ApiWeb.Utils.PushNotification.send_push_notification(notification_params)
      ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: params["email"]}, notification_params)
      render(conn, "user_follow.json", %{message: "User followed successfully"})
    %UserFollow{follow_status: :requested}  ->
      ApiWeb.Utils.PushNotification.send_push_notification(notification_params)
      ApiWeb.Utils.Email.send_email(%{first_name: first_name, email: params["email"]}, notification_params)
      render(conn, "user_follow.json", %{message: "Your follow request is sent"})
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
      Follow: swagger_schema do
        title "Follow"
        description "Follow"
        example %{
          userImage: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
          userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
          lastName: "Admin",
          isActive: true,
          firstName: "Super",
          baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
        }
      end,
      Follows: swagger_schema do
        title "Follows"
        description "List of Follows"
        example [
          %{
            userImage: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
            userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
            lastName: "Admin",
            isActive: true,
            firstName: "Super",
            baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
          },
          %{
            userImage: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
            userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
            lastName: "Admin",
            isActive: true,
            firstName: "Super",
            baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
          }
        ]
      end,
      CreateFollow: swagger_schema do
        title "Create Follow"
        description "Create Follow"
        properties do
          follower_id :string, "Follow ID"
        end
        example %{
          followed_id: "3a3a53d-1d55-40c2-b955-57f8d7be0232"
        }
      end,
      AcceptDeclineFollow: swagger_schema do
        title "Accept Decline Follow"
        description "Accept Decline Follow"
        properties do
          user_id :string, "Follower ID"
        end
        example %{
          user_id: "3a3a53d-1d55-40c2-b955-57f8d7be0232"
        }
      end,
      GetFollow: swagger_schema do
        title "Get List of Follower/Followed"
        description "Get List of Follower/Followed"
        properties do
          follower_id :string, "Follower ID"
          followed_id :string, "Followed ID"
        end
        example %{
          followed_id: "3a3a53d-1d55-40c2-b955-57f8d7be0232",
          following_id: "3a3a53d-1d55-40c2-b955-57f8d7be0232"
        }
      end

    }
  end
end
