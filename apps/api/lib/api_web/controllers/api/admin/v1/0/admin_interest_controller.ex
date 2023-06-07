#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule ApiWeb.Api.V1_0.AdminInterestController do
  #  @moduledoc """
  #  Manage Authenticated and Guest User Interests and user interest related queries.
  #  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  alias Data.Repo

  alias Data.Context
  import Ecto.Multi
  alias Data.Context.{Users, InterestTopics, UserEvents, UserInterests, Interests, UserEvents, UserBlocks, NotificationsRecords}
  alias Data.Schema.{UserInterestMeta,Interest, UserInterest, User}
  alias JetzyModule.AssetStoreModule
  alias SecureX.UserRoles


  #============================================================================
  # Controller Actions
  #============================================================================




  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/admin/admin-interest")
    summary("Get List OF All Interests")
    description("Get List OF Interests")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      page(:query, :integer, "Page no.", required: true)
      page_size(:query, :integer, "Page size.")
      search(:query, :string, "Search")
    end
    response(200, "Ok", Schema.ref(:ListInterest))
  end
  @doc """
  List or filter interests
  """

  def index(conn, %{"page" => page, "search" => search} = params) do
    page_size = params["page_size"] || 200
    admin_interests = Interests.get_interest_list_for_admin_with_search(search, page, page_size)
    render(conn, "admin_interests.json",
      %{admin_interest: admin_interests})
  end

  def index(conn, %{"page" => page} = params) do
    page_size = params["page_size"] || 200
    admin_interests = Interests.list(page, page_size)
    render(conn, "admin_interests.json",
      %{admin_interest: admin_interests})
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/admin/admin-interest")
    summary("Create Interests")
    description("It will Create a new Interests.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateInterest), "Create Interest params", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Create new interest
  """
  def create(conn, params) do
    %User{} = user = Guardian.Plug.current_resource(conn)
    {:ok, user_roles} = UserRoles.get(%{user_id: user.id})
    params = Map.put(params, "created_by_id", user.id)

    params = unless Map.has_key?(params, "is_private") do
      Map.put(params, "is_private", false)
    else
      params
    end
    case create_sage(conn, params) do
      {:ok, %{interest: interest}} ->
        render(conn, "interest.json", %{interests: interest})
      {:error, error} -> render(conn, "interest.json", %{error: error})
    end
  end


  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/admin/admin-interest/{id}")
    summary("Update Interest")
    description("Update Interest")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest ID", required: true)
      body(:body, Schema.ref(:UpdateInterest), "Update Interest Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Update interest.
  """
  def update(conn, %{"id" => id} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id),
         params <- check_public_interest(interest, params),
         image <- AssetStoreModule.upload_if_image_with_thumbnail(params, "image_name", "interest"),
         params <- (if is_tuple(image), do: Map.merge(params, %{"image_name" => elem(image, 0), "small_image_name" => elem(image, 1)}), else: params),
         {:ok, %Interest{} = interest} <- Context.update(Interest, interest, params) do
      render(conn, "interest.json", %{interests: interest})
    else
      nil -> render(conn, "interest.json", %{error: ["Interest not found"]})
      {:error, error} -> render(conn, "interest.json", %{error: error})
    end
  end

  # Handle private interest to be public while updating
  defp check_public_interest(interest, params) do
    params = if interest.is_private == false and Map.get(params, "is_private") == false do
      params
    else
      Map.replace(params, "is_private", true)
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/admin/admin-interest/{id}")
    summary("Delete Interests")
    description("Delete Interest")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Delete interest.
  """
  def delete(conn, %{"id" => id} = _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id),
         {:ok, %Interest{} = interest} <- Context.delete(interest) do
      render(conn, "message.json", %{message: "Interest Deleted Successfully"})
    else
      nil -> render(conn, "interest.json", %{error: ["Interest not found"]})
      {:error, error} -> render(conn, "interest.json", %{error: error})
    end
  end



  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # create_sage/2
  #----------------------------------------------------------------------------
  #  @doc """
  #  Query helper methods should be managed by repos/domain objects.
  #  """
  defp create_sage(_conn, params) do
    new()
    |> put(:params, params)
    |> run(:interest, &create_interest/2)
    |> run(:user_interest, &create_user_interest/2)
    |> run(:interest_meta, &create_user_interest_meta/2)
    |> Repo.transaction()
  end

  #----------------------------------------------------------------------------
  # create_interest/2
  #----------------------------------------------------------------------------
  #  @doc """
  #  Query helper methods should be managed by repos/domain objects.
  #  """
  defp create_interest(_param, %{params: params}) do
    params = case AssetStoreModule.upload_if_image_with_thumbnail(params, "image_name", "interests") do
      nil -> params
      {image_name, small_image_name} -> Map.merge(params, %{"image_name" => image_name, "small_image_name" => small_image_name})
    end
    case Context.create(Interest, params) do
      {:ok, interest} -> {:ok, interest}
      {:error, error} -> {:error, error}
    end
  end

  #----------------------------------------------------------------------------
  # create_user_interest/2
  #----------------------------------------------------------------------------
  #  @doc """
  #  Query helper methods should be managed by repos/domain objects.
  #  """

  def create_user_interest(_param, %{interest: interest}) do
    params = %{
      interest_id: interest.id,
      user_id: interest.created_by_id,
      is_active: true,
      status: :accepted,
      is_admin: true
    }
    case Context.create(UserInterest, params) do
      {:ok, user_interest} -> {:ok, user_interest}
      {:error, error} -> {:error, error}
    end
  end

  #----------------------------------------------------------------------------
  # create_user_interest_meta/2
  #----------------------------------------------------------------------------
  #  @doc """
  #  Query helper methods should be managed by repos/domain objects.
  #  """
  defp create_user_interest_meta(_param, %{interest: interest}) do
    case Context.create(UserInterestMeta, %{total_members: 1,
      last_member_joined_at: DateTime.utc_now(),
      last_message_at: DateTime.utc_now(),
      interest_id: interest.id
    }) do
      {:ok, user_interest_meta} -> {:ok, user_interest_meta}
      {:error, error} -> {:error, error}
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  #  @doc """
  #  Swagger MetaData.
  #  """
  def swagger_definitions do
    %{

      Interest:
        swagger_schema do
          title("Interest")
          description("Interest")

          example(%{
            responseData: %{
              smallImageName: "3085CD1E-B9CB-4BF8-B987-53DC95DFD121--635868644446670000--A3D50146-03AA-46F5-BB53-5080EB1F0C96.png",
              popularityScore: 0,
              interestName: "Business Traveler",
              interestId: "41fe4093-5be0-434f-9db6-82ceb9f91948",
              imageName: "BusinessTraveler.png",
              description: "Business Traveler",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              backgroundColour: "#f79432"
            }
          })
        end,
      ListInterest:
        swagger_schema do
          title("List Of Interest")
          description("List Of Interest")
          example([
            %{
              smallImageName: "3085CD1E-B9CB-4BF8-B987-53DC95DFD121--635868644446670000--A3D50146-03AA-46F5-BB53-5080EB1F0C96.png",
              popularityScore: 0,
              interestName: "Business Traveler",
              interestId: "41fe4093-5be0-434f-9db6-82ceb9f91948",
              imageName: "BusinessTraveler.png",
              description: "Business Traveler",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              backgroundColour: "#f79432",
              status: true,
              is_private: true
            },
            %{
              smallImageName: "3085CD1E-B9CB-4BF8-B987-53DC95DFD121--635868644446670000--A3D50146-03AA-46F5-BB53-5080EB1F0C96.png",
              popularityScore: 0,
              interestName: "Business Traveler",
              interestId: "41fe4093-5be0-434f-9db6-82ceb9f91948",
              imageName: "BusinessTraveler.png",
              description: "Business Traveler",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              backgroundColour: "#f79432",
              status: true,
              is_private: true
            }
          ])
        end,
      CreateInterest:
        swagger_schema do
          title("Create Interest")
          description("Create Interest")

          properties do
            interest_name(:string, "Interest")
            description(:string, "Test Interest")
            background_colour(:string, "#f79432")
            image_name(:string, "")
            is_private(:boolean, true)
          end

          example(%{
            interest_name: "Interest",
            description: "Test Interest",
            background_colour: "#f79432",
            image_name: "",
            is_private: true
          })
        end,
      UpdateInterest:
        swagger_schema do
          title("Update Interest")
          description("Update Interest")

          properties do
            interest_name(:string, "Interest")
            description(:string, "Test Interest")
            background_colour(:string, "#f79432")
            status(:boolean, true)
            image_name(:string, "test image")
            is_private(:boolean, true)
            is_group_private(:boolean, true)
          end

          example(%{
            interest_name: "Interest",
            description: "Test Interest",
            background_colour: "#f79432",
            status: true,
            image_name: "",
            baseUrl: "",
            is_private: true,
            is_group_private: true
          })
        end
    }
  end
end
