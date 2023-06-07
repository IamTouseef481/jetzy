#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserRoleController do
  @moduledoc """
  User Role controller.
  @todo - how does this differentiate from the other Role datastructures? - keith
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias SecureX.UserRoles, as: Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/user-roles/{id}"
    summary "Get UserRole By ID"
    description "Get UserRole By ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "User ID", required: true
    end
    response 200, "Ok", Schema.ref(:UserRole)
  end

  @doc """
  Get user role by id.
  """
  def show(conn, %{"id" => id}) do
    case Context.get(%{user_id: id}) do
      {:ok, user_roles} -> render(conn, "user_roles.json", %{user_roles: user_roles})
      {:error, error} -> render(conn, "user_role.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/user-roles"
    summary "Create UserRole"
    description "Create UserRole by adding correct user_id and role_id according to your case"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreateUserRole), "Create UserRole params", required: true
    end
    response 200, "Ok", Schema.ref(:UserRole)
  end

  @doc """
  Create new user role.
  """
  def create(conn, %{"user_id" => _} = params) do
    case Context.add(params) do
      {:ok, user_role} -> render(conn, "user_role.json", %{user_role: user_role})
      {:error, %Ecto.Changeset{}} -> render(conn, "user_role.json", %{error: "Invalid User ID or Role ID"})
      {:error, error} -> render(conn, "user_role.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/user-roles/{id}"
    summary "Delete UserRole"
    description "Delete UserRole"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "UserRole ID", required: true
    end
    response 200, "Ok", Schema.ref(:UserRole)
  end

  @doc """
  Delete user role.
  """
  def delete(conn, %{"id" => _} = params) do
    case Context.delete(params) do
      {:ok, user_role} -> render(conn, "user_role.json", %{user_role: user_role})
      {:error, error} -> render(conn, "user_role.json", %{error: error})
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
      UserRole: swagger_schema do
        title "UserRole"
        description "UserRole"
        example %{
          id: "cbe2d554-b72b-4a46-82ac-61fd0121d348",
          user_id: "abc2d554-b72b-4a46-82ac-61fd012112345",
          role_id: "super_admin",
          user: %{
            id: "abc2d554-b72b-4a46-82ac-61fd012112345"
          },
          role: %{
            id: "super_admin",
            name: "Super Admin"
          }
        }
      end,
      CreateUserRole: swagger_schema do
        title "Create UserRole"
        description "Create UserRole"
        properties do
          user_id :string, "User ID"
          role_id :string, "Role ID"
        end
        example %{
          user_id: "cbe2d554-b72b-4a46-82ac-61fd0121d348",
          role_id: "admin"
        }
      end
    }
  end
end
