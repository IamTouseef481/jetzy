#------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.Admin.V1_0.AdminCaptionController do
@moduledoc """
    Jetzy admin caption controller
  """

#============================================================================
# Uses, Requires, Aliases
#============================================================================
 use ApiWeb, :controller
 use PhoenixSwagger

 use Filterable.Phoenix.Controller
 alias Data.Context.{InfluencerMessages}
 alias Data.Schema.{InfluencerMessage}
 alias Data.Context
 alias ApiWeb.Utils.Common

#============================================================================
# Controller Actions
#============================================================================

#----------------------------------------------------------------------------
# index/2
#----------------------------------------------------------------------------
  swagger_path :index do
  get("/v1.0/admin/captions")
  summary("Get List of captions")
  description("Get List of captions")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
    page(:query, :integer, "Page", required: true)
    page_size(:query, :integer, "Page Size")
  end

  response(200, "Ok", Schema.ref(:ListCaptions))
  end

  @doc """
    Get list of Captions.
  """
  def index(conn, %{"page" => page} = params) do
    page_size = params["page_size"] || 20
    captions = InfluencerMessages.paginate_messages(%{type: "caption", page: page, page_size: page_size})
    conn
    |> render("captions.json", %{captions: captions})

  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
  get("/v1.0/admin/captions/{id}")
  summary("Get caption by id")
  description("Get caption by id")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
  id(:path, :string, "Id", required: true)
  end

  response(200, "Ok", Schema.ref(:Caption))
  end

  def show(conn, %{"id" => id}) do
    with %InfluencerMessage{} = caption <- Context.get_by(InfluencerMessage, [id: id, type: "caption"]) do
      conn
      |> render("caption.json", %{caption: caption})
      else
      nil ->
      conn
      |> render("caption.json", %{error: "No caption found"})
    end
  end

#----------------------------------------------------------------------------
# update/2
#----------------------------------------------------------------------------
  swagger_path :update do
  put("/v1.0/admin/captions/{id}")
  summary("Update Caption by id")
  description("Update Caption by id")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
    id(:path, :string, "Caption ID", required: true)
    body(:body, Schema.ref(:UpdateCaption), "Caption Params", required: true)
  end

  response(200, "Ok", Schema.ref(:Caption))

end

  @doc """
  Update
  """

  def update(conn, %{"id" => id} = params) do
    with %InfluencerMessage{} = caption <- Context.get_by(InfluencerMessage, [id: id, type: "caption"]),
         {:ok, %InfluencerMessage{} = caption} <- Context.update(InfluencerMessage, caption, params) do
       conn
       |> render("caption.json", %{caption: caption})
      else
      nil ->
      conn
      |> render("caption.json", %{error: "No caption found"})
      {:error, error} ->
      error = Common.decode_changeset_errors(error)
        conn
        |> render("caption.json", %{error: error})
    end
  end

#----------------------------------------------------------------------------
# delete/2
#----------------------------------------------------------------------------
  swagger_path :delete do
  PhoenixSwagger.Path.delete("/v1.0/admin/captions/{id}")
  summary("Delete Caption By Id")
  description("Delete Caption by Id")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
    id(:path, :string, "Id", required: true)
  end

  response(200, "Ok", Schema.ref(:Caption))

  end
  @doc """
  Delete
  """

  def delete(conn, %{"id" => id}) do
    with %InfluencerMessage{} = caption <- Context.get_by(InfluencerMessage, [id: id, type: "caption"]),
       {:ok, %InfluencerMessage{} = caption} <- Context.delete(caption) do
    conn
    |> render("caption.json", %{caption: caption})
  else
    nil ->
      conn
      |> render("caption.json", %{error: "No caption found"})
    {:error, error} ->
      error = Common.decode_changeset_errors(error)
      conn
      |> render("caption.json", %{error: error})
    end
  end

  swagger_path :create do
  post("/v1.0/admin/captions")
  summary("Create Caption")
  description("Create Caption")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
    body(:body, Schema.ref(:UpdateCaption), "Caption Params", required: true)
  end

  response(200, "Ok", Schema.ref(:Caption))

  end

  @doc """
  Create
  """

  def create(conn, params) do
    with params <- Map.put(params, "type", "caption"),
    {:ok, %InfluencerMessage{} = caption} <- Context.create(InfluencerMessage, params) do
      conn
      |> render("caption.json", %{caption: caption})
    else
      {:error, error} ->
        error = Common.decode_changeset_errors(error)
        conn
        |> render("caption.json", %{error: error})
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
    ListCaptions: swagger_schema do
      title("List of Captions")
      description("List of Captions")
      example(
        %{
          ResponseData: %{
            pagination: %{
              totalRows: 40,
              totalPages: 2,
              pageSize: 20,
              page: 1
            },
            data: [%{
              id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
              caption: "Natural"
            },
              %{
                id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
                caption: "Somewhere in Nature"
              }
            ]
          }})
    end,
    Caption: swagger_schema do
      title("Caption")
      description("Caption")
      example(
          %{
              id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
              caption: "Natural"
            })
    end,
    UpdateCaption: swagger_schema do
      title("Create/Update Caption Params")
      description("Create/Update Caption Params")
      properties do
        message(:string, "Caption")
      end
      example(
        %{
          message: "Natural"
        })
    end
  }
end

end