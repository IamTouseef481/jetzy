#------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------


defmodule ApiWeb.Api.Admin.V1_0.AdminCommentController do
  @moduledoc """
    Jetzy admin comment controller
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
    get("/v1.0/admin/influencer-comments")
    summary("Get List of comments")
    description("Get List of comments")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
    end

    response(200, "Ok", Schema.ref(:ListComments))
  end

  @doc """
    Get list of Comments.
  """
  def index(conn, %{"page" => page} = params) do
    page_size = params["page_size"] || 20
    comments = InfluencerMessages.paginate_messages(%{type: "comment", page: page, page_size: page_size})
    conn
    |> render("comments.json", %{comments: comments})

  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/admin/influencer-comments/{id}")
    summary("Get comment by id")
    description("Get comment by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Id", required: true)
    end

    response(200, "Ok", Schema.ref(:Comment))
  end

  def show(conn, %{"id" => id}) do
    with %InfluencerMessage{} = comment <- Context.get_by(InfluencerMessage, [id: id, type: "comment"]) do
      conn
      |> render("comment.json", %{comment: comment})
    else
      nil ->
        conn
        |> render("comment.json", %{error: "No comment found"})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/admin/influencer-comments/{id}")
    summary("Update Comment by id")
    description("Update Comment by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Comment ID", required: true)
      body(:body, Schema.ref(:UpdateComment), "Comment Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Comment))

  end

  @doc """
  Update
  """

  def update(conn, %{"id" => id} = params) do
    with %InfluencerMessage{} = comment <- Context.get_by(InfluencerMessage, [id: id, type: "comment"]),
         {:ok, %InfluencerMessage{} = comment} <- Context.update(InfluencerMessage, comment, params) do
      conn
      |> render("comment.json", %{comment: comment})
    else
      nil ->
        conn
        |> render("comment.json", %{error: "No comment found"})
      {:error, error} ->
        error = Common.decode_changeset_errors(error)
        conn
        |> render("comment.json", %{error: error})
    end
  end

  swagger_path :create do
    post("/v1.0/admin/influencer-comments")
    summary("Create Comment")
    description("Create Comment")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UpdateComment), "Comment Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Comment))

  end

  @doc """
  Create
  """

  def create(conn, params) do
    with params <- Map.put(params, "type", "comment"),
         {:ok, %InfluencerMessage{} = comment} <- Context.create(InfluencerMessage, params) do
      conn
      |> render("comment.json", %{comment: comment})
    else
      {:error, error} ->
        error = Common.decode_changeset_errors(error)
        conn
        |> render("comment.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/admin/influencer-comments/{id}")
    summary("Delete Comments By Id")
    description("Delete Comments by Id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Id", required: true)
    end

    response(200, "Ok", Schema.ref(:Comment))

  end
  @doc """
  Delete
  """

  def delete(conn, %{"id" => id}) do
    with %InfluencerMessage{} = comment <- Context.get_by(InfluencerMessage, [id: id, type: "comment"]),
         {:ok, %InfluencerMessage{} = comment} <- Context.delete(comment) do
      conn
      |> render("comment.json", %{comment: comment})
    else
      nil ->
        conn
        |> render("comment.json", %{error: "No comment found"})
      {:error, error} ->
        error = Common.decode_changeset_errors(error)
        conn
        |> render("comment.json", %{error: error})
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
      ListComments: swagger_schema do
        title("List of Comments")
        description("List of Comments")
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
                comment: "Natural",
                category: "Common"
              },
                %{
                  id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
                  comment: "Somewhere in Nature",
                  category: "nature"
                }
              ]
            }})
      end,
      Comment: swagger_schema do
        title("Comment")
        description("Comment")
        example(
          %{
            id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
            comment: "Natural",
            category: "Common"
          })
      end,
      UpdateComment: swagger_schema do
        title("Create/Update Comment Params")
        description("Create/Update Comment Params")
        properties do
          message(:string, "Comment")
          category(:string, "Category")
        end
        example(
          %{
            message: "Natural",
            category: "Prime"
          })
      end
    }
  end
end