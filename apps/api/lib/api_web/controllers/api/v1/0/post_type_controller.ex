#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.PostTypeController do
  @moduledoc """
  Manage post type definitions.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Schema.ShoutoutType

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get "/v1.0/post-types"
    summary "Get List OF Post Types"
    description "Get List OF Post Types"
    produces "application/json"
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListPostType)
  end

  @doc """
  Get list of post types.
  """
  def index(conn, _) do
    post_types = Context.ShoutoutTypes.list_shoutout_types()
    render(conn, "post_types.json", %{post_types: post_types})
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/post-types/{id}"
    summary "Get Post Types By ID"
    description "Get Post Types By ID"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Post Types ID", required: true
    end
    response 200, "Ok", Schema.ref(:PostType)
  end

  @doc """
  Get specific post type definition.
  """
  def show(conn, %{"id" => id}) do
    case Context.get(ShoutoutType, id) do
      nil -> render(conn, "post_type.json", %{error: ["Post Type does not exist"]})
      %{} = post_type -> render(conn, "post_type.json", %{post_type: post_type})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/post-types"
    summary "Create Post Types"
    description "Create Post Types"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      body :body, Schema.ref(:CreatePostType), "Create Post Type params", required: true
    end
    response 200, "Ok", Schema.ref(:PostType)
  end

  @doc """
  Create new post type definition.
  """
  def create(conn, params) do
    case Context.create(ShoutoutType, params) do
      {:ok, post_type} -> render(conn, "post_type.json", %{post_type: post_type})
      {:error, error} -> render(conn, "post_type.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put "/v1.0/post-types/{id}"
    summary "Update Post Type"
    description "Update Post Type"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "Post Type ID", required: true
      body :body, Schema.ref(:UpdatePostType), "Update Post Type Params", required: true
    end
    response 200, "Ok", Schema.ref(:PostType)
  end

  @doc """
  Update post type definition.
  """
  def update(conn, %{"id" => id} = params) do
    with %ShoutoutType{} = post_type <- Context.get(ShoutoutType, id),
         {:ok, %ShoutoutType{} = post_type} <- Context.update(ShoutoutType, post_type, params) do
      render(conn, "post_type.json", %{post_type: post_type})
    else
      nil -> render(conn, "post_type.json", %{error: ["postType not found"]})
      {:error, error} -> render(conn, "post_type.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/post-types/{id}"
    summary "Delete PostTypes"
    description "Delete Post Type"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      id :path, :string, "PostType ID", required: true
    end
    response 200, "Ok", Schema.ref(:PostType)
  end

  @doc """
  Delete post type definition.
  """
  def delete(conn, %{"id" => id} = _params) do
    with %ShoutoutType{} = post_type <- Context.get(ShoutoutType, id),
         {:ok, %ShoutoutType{} = post_type} <- Context.delete(post_type) do
      render(conn, "post_type.json", %{post_type: post_type})
    else
      nil -> render(conn, "post_type.json", %{error: ["postType not found"]})
      {:error, error} -> render(conn, "post_type.json", %{error: error})
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
      PostType: swagger_schema do
        title "Resource"
        description "Resource"
        example %{
          id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
          title: "Post",
          latitude: 2.2222222,
          longitude: 783.224552,
          image_name: "Test image",
          image_ext: "test image",
          is_shared: true,
          image_sync: "test",
          updated_by: "test user",
          old_moment: "OLD test",
          user_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
          shoutout_type_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
          post_type_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11"
        }
      end,
      ListPostType: swagger_schema do
        title "List Of PostType"
        description "List Of PostType"
        example [
          %{
            id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            title: "ShoutOut",
            latitude: 2.2222222,
            longitude: 783.224552,
            image_name: "Test image",
            image_ext: "test image",
            is_shared: true,
            image_sync: "test",
            updated_by: "test user",
            old_moment: "OLD test",
            user_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            shoutout_type_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            post_type_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11"
          },
          %{
            id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            title: "ShoutOut",
            latitude: 2.2222222,
            longitude: 783.224552,
            image_name: "Test image",
            image_ext: "test image",
            is_shared: true,
            image_sync: "test",
            updated_by: "test user",
            old_moment: "OLD test",
            user_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            shoutout_type_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
            post_type_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11"
          }
        ]
      end,
      CreatePostType: swagger_schema do
        title "Create Resource"
        description "Create Resource"
        properties do
          title :string, "Title"
          latitude :float, "Latitude"
          longitude :float, "Longitude"
          image_name :string, "Image Name"
          image_ext :string, "Image Text"
          is_shared :boolean, "Is Shard"
          image_sync :string, "Image Sync"
          updated_by :string, "Updated By"
          old_moment :string, "Old Moment"
          user_id :string, "User ID"
          shoutout_type_id :string, "ShoutOut Type ID"
          post_type_id :string, "Post Type ID"
        end
        example %{
          title: "Post",
          latitude: 2.2222222,
          longitude: 783.224552,
          image_name: "Test image",
          image_ext: "test image",
          is_shared: true,
          image_sync: "test",
          updated_by: "test user",
          old_moment: "OLD test",
          user_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
          shoutout_type_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
          post_type_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11"
        }
      end,
      UpdatePostType: swagger_schema do
        title "Update Post Type"
        description "Update Post Type"
        properties do
          id :string, "Title"
          title :string, "Title"
          latitude :float, "Latitude"
          longitude :float, "Longitude"
          image_name :string, "Image Name"
          image_ext :string, "Image Text"
          is_shared :boolean, "Is Shard"
          image_sync :string, "Image Sync"
          updated_by :string, "Updated By"
          old_moment :string, "Old Moment"
          user_id :string, "User ID"
          shoutout_type_id :string, "ShoutOut Type ID"
          post_type_id :string, "Post Type ID"
        end
        example %{
          title: "Post Type",
          latitude: 2.2222222,
          longitude: 783.224552,
          image_name: "Test image",
          image_ext: "test image",
          image_sync: "test",
          old_moment: "OLD test",
          user_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11"
        }
      end
    }
  end
end
