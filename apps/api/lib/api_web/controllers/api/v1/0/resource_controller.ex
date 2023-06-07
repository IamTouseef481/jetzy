#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.ResourceController do
  @moduledoc """
  Manage resources
  @todo What is a resource in this context? -- kebrings
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias SecureX.Res, as: Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/resources"
    summary "Get List OF Resources"
    description "Get List OF Resources"
    produces "application/json"
    parameters do
      page :query, :integer, "Enter Page Number For pagination"
      page_size :query, :integer, "Enter Page Size"
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListResource)
  end

  @doc """
  Get list of resources.
  """
  def index(conn, input) do
    Context.list(input["page"], input["page_size"])
    |> then(fn
      data -> render(conn, "resources.json", %{resources: data})
    end)
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/resources/{id}"
    summary "Get Resource By ID"
    description "Get Resource By ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Resource ID", required: true
    end
    response 200, "Ok", Schema.ref(:Resource)
  end

  @doc """
  get specific resource by id.
  """
  def show(conn, %{"id" => id}) do
    case Context.get(%{role: id}) do
      {:ok, resource} -> render(conn, "resource.json", %{resource: resource})
      {:error, error} -> render(conn, "resource.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/resources"
    summary "Create Resource"
    description "Create Resource"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreateResource), "Create Resource params", required: true
    end
    response 200, "Ok", Schema.ref(:Resource)
  end

  @doc """
  Create new resource.
  """
  def create(conn, %{"res" => _} = params) do
    case Context.add(params) do
      {:ok, resource} -> render(conn, "resource.json", %{resource: resource})
      {:error, error} -> render(conn, "resource.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/resources/{id}"
    summary "Update Resource"
    description "Update Resource"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Resource ID", required: true
      body :body, Schema.ref(:UpdateResource), "Update Resource Params", required: true
    end
    response 200, "Ok", Schema.ref(:Resource)
  end

  @doc """
  Update resource.
  """
  def update(conn, %{"id" => _} = params) do
    case Context.update(params) do
      {:ok, resource} -> render(conn, "resource.json", %{resource: resource})
      {:error, error} -> render(conn, "resource.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/resources/{id}"
    summary "Delete Resource"
    description "Delete Resource"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Resource ID", required: true
    end
    response 200, "Ok", Schema.ref(:Resource)
  end

  @doc """
  Delete resource.
  """
  def delete(conn, %{"id" => id} = _params) do
    case Context.delete(%{res: id}) do
      {:ok, resource} -> render(conn, "resource.json", %{resource: resource})
      {:error, error} -> render(conn, "resource.json", %{error: error})
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================s
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      Resource: swagger_schema do
        title "Resource"
        description "Resource"
        example %{
          id: "users",
          name: "Users"
        }
      end,
      ListResource: swagger_schema do
        title "List Of Resources"
        description "List Of Resources"
        example [
          %{
            id: "users",
            name: "Users"
          },
          %{
            id: "shoutouts",
            name: "Shout Outs"
          }
        ]
      end,
      CreateResource: swagger_schema do
        title "Create Resource"
        description "Create Resource"
        properties do
          res :string, "Resource"
        end
        example %{
          res: "comments",
        }
      end,
      UpdateResource: swagger_schema do
        title "Update Resource"
        description "Update Resource"
        properties do
          res :string, "Comments Reply"
        end
        example %{
          res: "Comments Reply"
        }
      end
    }
  end
end
