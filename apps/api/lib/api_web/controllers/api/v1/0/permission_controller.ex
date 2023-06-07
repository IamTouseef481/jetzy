#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.PermissionController do
  @moduledoc """
  Manage permissions.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias SecureX.Permissions, as: Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/roles/{ids}/permissions"
    summary "Get List Of Permissions"
    description "Get List Of Permissions"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      ids :path, :string, "Enter Roles i.e, super_admin,admin", required: true
      page :query, :integer, "Enter Page Number For pagination"
      page_size :query, :integer, "Enter Page Size"
    end
    response 200, "Ok", Schema.ref(:ListPermission)
  end
  @doc """
  Get list of permissions.
  @todo what is the purpose of passing in a coma delimited list of roles, are we returning matches of permissions for those roles grouped together? - keith
  """
  def index(conn, %{"ids" => _} = input) do
    roles = String.split(input["ids"], ",")
    Context.list(roles, input["page"], input["page_size"])
    |> then(fn
      {:error, error} ->
        render(conn, "permission.json", %{error: error})

        {:ok, data} ->
          render(conn, "permissions.json", %{data: data})
    end)
  end

  def index(conn, _), do: render(conn, "permission.json", %{error: "Invalid Params"})

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/permissions/{id}"
    summary "Get Permission By ID"
    description "Get Permission By ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Permission ID", required: true
    end
    response 200, "Ok", Schema.ref(:Permission)
  end
  @doc """
  @todo this was not implented despite the swagger path.
  """
  def show(_conn, _params) do
    throw "NYI"
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/permissions"
    summary "Create Permission"
    description "Create Permission
    GET and permission == 1
    [GET, POST] and permission == 2
    [GET, POST, UPDATE, PUT] and permission == 3
    [GET, POST, UPDATE, PUT, DELETE and permission == 4"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreatePermission), "Create Permission params", required: true
    end
    response 200, "Ok", Schema.ref(:Permission)
  end
  @doc """
  Create permissions for given role.
  """
  def create(conn, %{"role_id" => _, "resource_id" => _} = params) do
    case Context.add(params) do
      {:ok, permission} -> render(conn, "permission.json", %{permission: permission})
      {:error, %Ecto.Changeset{}} -> render(conn, "permission.json", %{error: ["Invalid Resource ID or Role ID"]})
      {:error, error} -> render(conn, "permission.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/permissions/{id}"
    summary "Update Permission"
    description "Update Permission
    GET and permission == 1
    [GET, POST] and permission == 2
    [GET, POST, UPDATE, PUT] and permission == 3
    [GET, POST, UPDATE, PUT, DELETE and permission == 4"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Permission ID", required: true
      body :body, Schema.ref(:UpdatePermission), "Update Permission Params", required: true
    end
    response 200, "Ok", Schema.ref(:Permission)
  end
  @doc """
  Update permission.
  """
  def update(conn, %{"id" => _} = params) do
    case Context.update(params) do
      {:ok, permission} -> render(conn, "permission.json", %{permission: permission})
      {:error, %Ecto.Changeset{}} -> render(conn, "permission.json", %{error: ["Invalid Resource ID or Role ID"]})
      {:error, error} -> render(conn, "permission.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/permissions/{id}"
    summary "Delete Permission"
    description "Delete Permission"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Permission ID", required: true
    end
    response 200, "Ok", Schema.ref(:Permission)
  end
  @doc """
  Delete permission.
  """
  def delete(conn, %{"id" => _} = params) do
    case Context.delete(params) do
      {:ok, permission} -> render(conn, "permission.json", %{permission: permission})
      {:error, error} -> render(conn, "permission.json", %{error: error})
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
      Permission: swagger_schema do
        title "Permission"
        description "Permission"
        example %{
          id: "cbe2d554-b72b-4a46-82ac-61fd0121d348",
          resource_id: "users",
          permission: -1,
          role_id: "super_admin"
        }
      end,
      ListPermission: swagger_schema do
        title "List Of Permissions"
        description "List Of Permissions"
        example [
          %{
            id: "cbe2d554-b72b-4a46-82ac-61fd0121d348",
            resource_id: "users",
            permission: 4,
            role_id: "super_admin"
          },
          %{
            id: "bbe2d554-b72b-4a46-82ac-61fd0121d447",
            resource_id: "commnets",
            permission: 4,
            role_id: "super_admin"
          }
        ]
      end,
      CreatePermission: swagger_schema do
        title "Create Permission"
        description "Create Permission"
        properties do
          permission :integer, "Permission"
          role_id :string, "Role ID"
          resource_id :string, "Resource ID"
        end
        example %{
          resource_id: "comments",
          permission: 4,
          role_id: "super_admin"
        }
      end,
      UpdatePermission: swagger_schema do
        title "Update Permission"
        description "Update Permission"
        properties do
          role :string, "Permission"
          permissions :array, "List Of Permissions"
        end
        example %{
          id: "bbe2d554-b72b-4a46-82ac-61fd0121d448",
          resource_id: "comments",
          permission: 4,
          role_id: "super_admin"
        }
      end,
    }
  end
end
