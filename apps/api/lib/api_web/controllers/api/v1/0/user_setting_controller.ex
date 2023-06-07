#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserSettingController do
  @moduledoc """
  Manage active user's user settings.
  """
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias Data.Schema.{UserSetting}

  alias Data.Context
  alias Data.Context.UserSettings

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # show_user_settings/2
  #----------------------------------------------------------------------------
  swagger_path :show_user_settings do
    get("/v1.0/user-settings")
    summary("Show User Settings")
    description("Show User Settings")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:UserSetting))
    security([%{Bearer: []}])
  end

  @doc """
  Get user settings.
  """
  def show_user_settings(conn, _) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    user_settings = Context.get_by(UserSetting, [user_id: current_user_id])
    render(conn, "user_settings.json", %{user_settings: UserSettings.preload_all(user_settings, [:user])})
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/user-settings")
    summary("Update User Settings")
    description("Update User Settings")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      body(:body, Schema.ref(:UpdateSetting), "Update User Settings", required: true)
    end
    response(200, "Ok", Schema.ref(:UserSetting))
    security([%{Bearer: []}])
  end

  @doc """
  Update user settings.
  """
  def update(conn, params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %{} = user_settings <- Context.get_by(UserSetting, [user_id: current_user_id]),
         {:ok, data} <- Context.update(UserSetting, user_settings, params) do
         render(conn, "user_settings.json", %{user_settings: UserSettings.preload_all(data, [:user])})
      else
         {:error, %Ecto.Changeset{} = changeset} ->
           render(conn, "user_settings.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
         nil -> render(conn, "user_settings.json", %{error: "User not found"})
         _ -> render(conn, "user_settings.json", %{error: "Something went wrong."})
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
      UserSetting:
        swagger_schema do
          title("User Settings")
          description("User Settings")
          properties do
            id(:string, "ID")
            user_id(:string, "User ID")
            is_show_on_profile(:boolean, "Is Show On Profile")
            is_push_notification(:boolean, "Is Push Notification")
            is_enable_chat(:boolean, "Is Enable Chat")
            is_groupchat_enable(:boolean, "Is Group chat enable")
            is_moments_enable(:boolean, "Is moments enable")
            is_info(:boolean, "Is info")
            user_invite_type(:integer, "User Invite Type")
            un_subscribe(:boolean, "Un Subscribe")
            is_profile_image_sync(:boolean, "Is Profile Image Sync")
            is_follow_public(:boolean, "Is Follow Public")
            is_show_followings(:boolean, "Is show Followings")
          end
          example(%{
            user: %{
              userId: "13a3a53d-1d55-40c2-b955-57f8d7be0232",
              first_name: "First name",
              last_name: "Last name",
              user_image: "user/3f665047-9373-4335-9d39-3099a0eb85ba.png"
            },
            is_follow_public: true,
            is_show_followings: true
          })
        end,
      UpdateSetting:
        swagger_schema do
          title("Update User Settings")
          description("Update User Settings")
          properties do
            is_show_on_profile(:boolean, "Is Show On Profile")
            is_push_notification(:boolean, "Is Push Notification")
            is_enable_chat(:boolean, "Is Enable Chat")
            is_groupchat_enable(:boolean, "Is Group chat enable")
            is_moments_enable(:boolean, "Is moments enable")
            is_info(:boolean, "Is info")
            user_invite_type(:integer, "User Invite Type")
            un_subscribe(:boolean, "Un Subscribe")
            is_profile_image_sync(:boolean, "Is Profile Image Sync")
            is_follow_public(:boolean, "Is Follow Public")
            is_show_followings(:boolean, "Is show Followings")
          end
          example(%{
            is_follow_public: true,
            is_show_followings: true,
            is_push_notification: true,
            is_show_on_profile: true,
            is_enable_chat: true,
            is_groupchat_enable: true,
            is_moments_enable: true,
            is_info: true,
            is_profile_image_sync: true
#            is_show_followings: true
          })
        end
    }
  end
end
