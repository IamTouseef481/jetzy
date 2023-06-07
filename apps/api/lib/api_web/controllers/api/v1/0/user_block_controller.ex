#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserBlockController do
  @moduledoc """
  Manage blocking/unblocking users.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Schema.{UserBlock, User, UserFollow}
  alias Data.Context.UserBlocks

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index\2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/user-blocks"
    summary "Get List OF User Blocks"
    description "Get List OF User Blocks"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      page(:query, :integer, "Page no.", required: true)
    end
    response 200, "Ok", Schema.ref(:ListBlock)
  end

  @doc """
  Get list of users blocked by active user.
  """
  def index(conn, %{"page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    user_blocks = UserBlocks.get_by_user(user_id, page)
    render(conn, "user_blocks.json", %{user_blocks: user_blocks})
  end

  #----------------------------------------------------------------------------
  # block_unblock_user\2
  #----------------------------------------------------------------------------
  swagger_path :block_unblock_user do
    post "/v1.0/user-blocks"
    summary "Block or Unblock a User"
    description "Used to block a user OR Unblock them by ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreateBlock), "Block/Unblock a User", required: true
    end
    response 200, "Ok", Schema.ref(:Block)
  end

  @doc """
  Toggle block flag of a user for active user.
  """
  def block_unblock_user(conn, %{"user_to_id" => user_to_id, "is_blocked" => is_blocked} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} <- Context.get(User, user_to_id),
         false <- is_deleted or is_deactivated or is_self_deactivated,
         user_block <- Context.get_by(UserBlock, [user_from_id: user_id, user_to_id: user_to_id]) do
          case user_block do
            %{is_blocked: true} ->
              if !is_blocked,
                 do: (Context.update(UserBlock, user_block, %{is_blocked: is_blocked})
                      render(conn, "user_block.json", %{user_block: UserBlocks.preload_blocked_users(user_block)})),
                 else: render(conn, "user_block.json", %{error: "User already blocked"})
            %{is_blocked: false} ->
              if is_blocked,
                do: (Context.update(UserBlock, user_block, %{is_blocked: is_blocked})
#                     unfollow_blocked_users(user_id, user_to_id)
#                     unfollow_blocked_users(user_to_id, user_id)
                     render(conn, "user_block.json", %{user_block: UserBlocks.preload_blocked_users(user_block)})),
                else: render(conn, "user_block.json", %{error: "User already unblocked"})
            nil ->
              if is_blocked,
                 do: ({:ok, user_block} = Context.create(UserBlock, Map.put(params, "user_from_id", user_id))
#                      unfollow_blocked_users(user_to_id, user_id)
#                      unfollow_blocked_users(user_id, user_to_id)
                      render(conn, "user_block.json", %{user_block: UserBlocks.preload_blocked_users(user_block)})),
                 else: render(conn, "user_block.json", %{error: "The user requested to unblock is not in blocked users list"})
            _ -> render(conn, "user_block.json", %{error: "Something went wrong"})
          end
      else
        nil -> render(conn, "user_block.json", %{error: "User does not exist"})
        true -> render(conn, "user_block.json", %{error: "User either deactivated or deleted"})
        _ -> render(conn, "user_block.json", %{error: "Something went wrong"})
    end
  end
  def block_unblock_user(conn, _) do
    render(conn, "user_block.json", %{error: "Invalid Params"})
  end

  defp unfollow_blocked_users(follower_id, followed_id) do
    case Context.get_by(UserFollow, [follower_id: follower_id, followed_id: followed_id]) do
       %{follow_status: :requested} = follow -> Context.update(UserFollow, follow, %{follow_status: :unfollowed})
       %{follow_status: :followed} = follow -> Context.update(UserFollow, follow, %{follow_status: :unfollowed})
       _ -> {:ok, "no record"}
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
      Block: swagger_schema do
        title "Blocked User"
        description "Blocked User"
        example %{
          user_image: "",
          user_id: "b640adbb-75a3-47a4-b3b3-77ef718d2ah1",
          first_name: "First Name",
          last_name: "Last Name",
          is_active: true,
        }
      end,
      ListBlock: swagger_schema do
        title "List of Blocked User"
        description "List of Blocked User"
        example [
          %{
            user_image: "",
            user_id: "b640adbb-75a3-47a4-b3b3-77ef718d2ah1",
            first_name: "First Name",
            last_name: "Last Name",
            is_active: true,
          },
          %{
            user_image: "",
            user_id: "b640adbb-75a3-47a4-b3b3-77ef718d2ah1",
            first_name: "First Name",
            last_name: "Last Name",
            is_active: true,
          }
        ]
      end,
      CreateBlock: swagger_schema do
        title "Create User block"
        description "Create User block"
        properties do
          user_to_id :string, "ID of the User to Block/Unblock"
          is_blocked :boolean, "Set true for block, false for unblock"
        end
        example %{
          user_to_id: "c641adbb-77d4-47a4-b3b3-77ef718d2abc",
          is_blocked: true
        }
      end,
    }
  end
end
