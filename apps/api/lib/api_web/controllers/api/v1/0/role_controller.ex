#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.RoleController do
  @moduledoc """
  Manage Roles API.
  @todo what is a role in this context? Permission Group?
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias SecureX.Roles, as: Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/roles"
    summary "Get List OF Roles"
    description "Get List OF Roles"
    produces "application/json"
    parameters do
      page :query, :integer, "Enter Page Number For pagination"
      page_size :query, :integer, "Enter Page Size"
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListRole)
  end

  @doc """
  Get list of roles.
  """
  def index(conn, input) do
    Context.list(input["page"], input["page_size"])
    |> then(fn roles -> render(conn, "roles.json", %{roles: roles}) end)
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/roles/{id}"
    summary "Get Role By ID"
    description "Get Role By ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Role ID", required: true
    end
    response 200, "Ok", Schema.ref(:Role)
  end

  @doc """
  Get specific role by id.
  """
  def show(conn, %{"id" => id}) do
    case Context.get(%{role: id}) do
      {:ok, role} -> render(conn, "role.json", %{role: role})
      {:error, error} -> render(conn, "role.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/roles"
    summary "Create Role"
    description "Create Role"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreateRole), "Create Role params", required: true
    end
    response 200, "Ok", Schema.ref(:Role)
  end

  @doc """
  Create new role.
  """
  def create(conn, %{"role" => _} = params) do
    case Context.add(params) do
      {:ok, role} -> render(conn, "role.json", %{role: role})
      {:error, error} -> render(conn, "role.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/roles/{id}"
    summary "Update Role"
    description "Update Role"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Role ID", required: true
      body :body, Schema.ref(:UpdateRole), "Update Role Params", required: true
    end
    response 200, "Ok", Schema.ref(:Role)
  end

  @doc """
  Update existing role.
  """
  def update(conn, %{"id" => _} = params) do
    case Context.update(params) do
      {:ok, role} -> render(conn, "update_role.json", %{role: role})
      {:error, error} -> render(conn, "role.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/roles/{id}"
    summary "Delete Role"
    description "Delete Role"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Role ID", required: true
    end
    response 200, "Ok", Schema.ref(:Role)
  end

  @doc """
  Delete existing role.
  """
  def delete(conn, %{"id" => _} = params) do
    case Context.delete(params) do
      {:ok, role} -> render(conn, "role.json", %{role: role})
      {:error, error} -> render(conn, "role.json", %{error: error})
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
      Role: swagger_schema do
        title "Role"
        description "Role"
        example %{
          id: "admin",
          name: "Admin",
          permissions: [
            %{resource_id: "users", permission: -1, role_id: "super_admin"},
            %{resource_id: "employees", permission: -1, role_id: "super_admin"},
            %{resource_id: "customer", permission: -1, role_id: "super_admin"}
          ]
        }
      end,
      ListRole: swagger_schema do
        title "List Of Roles"
        description "List Of Roles"
        example [
          %{
            id: "admin",
            name: "Admin",
            permissions: [
              %{resource_id: "users", permission: -1, role_id: "super_admin"},
              %{resource_id: "employees", permission: -1, role_id: "super_admin"},
              %{resource_id: "customer", permission: -1, role_id: "super_admin"}
            ]
          },
          %{
            id: "super_admin",
            name: "Super Admin",
            permissions: [
              %{resource_id: "users", permission: -1, role_id: "super_admin"},
              %{resource_id: "employees", permission: -1, role_id: "super_admin"},
              %{resource_id: "customer", permission: -1, role_id: "super_admin"}
            ]
          }
        ]
      end,
      CreateRole: swagger_schema do
        title "Create Role"
        description "Create Role"
        properties do
          role :string, "Role"
        end
        example %{
          role: "super_admin",
        }
      end,
      UpdateRole: swagger_schema do
        title "Update Role"
        description "Update Role"
        properties do
          role :string, "Role"
          permissions :array, "List Of Permissions"
        end
        example %{
          role: "Admin",
          permissions: [
            %{resource_id: "users", permission: -1, role_id: "admin"}
          ]
        }
      end
    }
  end
end
