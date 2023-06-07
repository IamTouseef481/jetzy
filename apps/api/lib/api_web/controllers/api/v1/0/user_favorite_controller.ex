#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserFavoriteController do

  @moduledoc """
  Manage user favorite places, businesses, etc.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.{UserFavorites}
  alias Data.Schema.{UserFavorite, UserFavoriteType, User}
  alias ApiWeb.Utils.Common
  alias JetzyModule.AssetStoreModule, as: AssetStore
  alias ApiWeb.Utils.PushNotification

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # user_favourite/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/user-favourite")
    summary("User Favourite")
    description("User Favourite")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      user_id :query, :string, "User  ID"
      user_favourite_type_id :query, :string, "User Favourite Type Id", required: true
      page :query, :integer, "Page", required: true
    end
    response(200, "Ok", Schema.ref(:User))
    security([%{Bearer: []}])
  end

  @doc """
  List of user favourite.
  """

  def index(conn, %{"user_favourite_type_id" => user_favourite_type_id,  "page" => page} = params) do
    user_id = if params["user_id"] do
      params["user_id"]
    else
      %{id: user_id} = Guardian.Plug.current_resource(conn)
      user_id
    end
    case UserFavorites.get_by_type(user_id, user_favourite_type_id, page) do
      user_favorites -> render(conn, "user_favorites.json", %{user_favorites: user_favorites})
    end
  end

    #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/user-favourite")
    summary("Create User Favourite")
    description("Create a new User Favourite")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateUserFavorite), "Create a new user Favourite from params", required: true)
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  @doc """
  Favorite city/restaurant,etc.
  """
  def create(conn, params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    params = case AssetStore.upload_if_image_with_thumbnail(params, "image", "user-favorite") do
      nil -> params
      {image, small_image} -> Map.merge(params, %{"image" => image, "small_image" => small_image})
    end
    params = Map.merge(params, %{"user_id" => user_id})
    case Context.create(UserFavorite, params) do
      {:ok, user_favorite} ->
          render(conn, "user_favorite.json", user_favorite: user_favorite)
     {:error, %Ecto.Changeset{} = changeset} ->
       render(conn, "error.json", %{error: Common.decode_changeset_errors(changeset)})
      {:error, error} ->
        render(conn, "error.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/user-favourite/{id}")
    summary("Get User Favourite By ID")
    description("Get User Favourite ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "User Favourite ID", required: true)
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  @doc """
  Show user favorite
  """
  def show(conn, %{"id" => id}) do
    case Context.get(UserFavorite, id) do
      nil ->
        render(conn, "error.json", %{error: ["User event does not exist"]})
      %{} = user_favorite ->
        render(conn, "user_favorite.json", user_favorite: user_favorite)
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/user-favourite/{id}")
    summary("Update User Favourite")
    description("Update User Favourite")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "User Favourite ID", required: true)
      body(:body, Schema.ref(:UpdateUserFavorite), "Update User Favourite Params", required: true)
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  @doc """
  Update user favorite.
  """
  def update(conn, %{"id" => id} = params) do
    with %UserFavorite{} = user_favorite <- Context.get(UserFavorite, id),
         image <- AssetStore.upload_if_image_with_thumbnail(params, "image", "user_favorite"),
         params <-  (if is_tuple(image), do: Map.merge(params, %{"image" => elem(image, 0), "small_image" => elem(image, 1)}), else: params),
         {:ok, %UserFavorite{} = user_favorite} <- Context.update(UserFavorite, user_favorite, params) do
      render(conn, "user_favorite.json", user_favorite: user_favorite)
    else
      nil -> render(conn, "error.json", %{error: ["User Favorite not found"]})
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "error.json", %{error: Common.decode_changeset_errors(changeset)})
      {:error, error} -> render(conn, "error.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/user-favourite/{id}")
    summary("Delete User Favourite")
    description("Delete User Favourite")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "User Favourite ID", required: true)
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  def delete(conn, %{"id" => id}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    case Context.get_by(UserFavorite, [user_id: user_id, id: id]) do
      nil ->
        render(conn, "error.json", %{error: ["User event does not exist"]})
      %{} = user_favorite ->
        {:ok, %UserFavorite{} = user_favorite} = Context.delete(user_favorite)
        render(conn, "user_favorite.json", user_favorite: user_favorite)
    end
  end

  #----------------------------------------------------------------------------
  # ask_for_recommendation/2
  #----------------------------------------------------------------------------
  swagger_path :ask_for_recommendation do
    post("/v1.0/ask-for-recommendation")
    summary("Ask users to add recommendations")
    description("Ask users to add recommendations")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:RecommendationParams), "Create a new user Favourite from params", required: true)
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  @doc """
  Ask users for recommendations
  """
  def ask_for_recommendation(conn, %{"user_id" => id, "type" => type}) do
    %{id: user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    with %User{} <- Context.get(User, id) || :user_not_found,
         %UserFavoriteType{} <- Context.get(UserFavoriteType, type) || :type_not_found,
         true <- user_id != id do
      push_notification_params = %{
        "keys" => %{
          "first_name" => first_name,
          "last_name" => last_name,
          "favorite" => type
        },
        "event" => "ask_for_recommendation",
        "sender_id" => user_id,
        "user_id" => id,
        "type" => "ask_for_recommendation"
      }
      PushNotification.send_push_notification(push_notification_params)
      conn
      |> put_status(200)
      |> json(
           %{success: true, message: "Asked for recommendation"}
         )
    else
      :user_not_found ->
        conn
        |> render("error.json", %{error: "User not found"})
      :type_not_found ->
        conn
        |> render("error.json", %{error: "No recommendation found"})
      false ->
        conn
        |> render("error.json", %{error: "Cannot ask yourself for recommendation"})
    end
  end

  #----------------------------------------------------------------------------
  # nearby_recommendations/2
  #----------------------------------------------------------------------------
  swagger_path :nearby_recommendations do
    get("/v1.0/nearby-recommendations")
    summary("Get nearby recommendations of trusted users")
    description("Get nearby recommendations of trusted users")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      latitude(:query, :float, "Latitude")
      longitude(:query, :float, "Longitude")
      radius(:query, :float, "Radius")
      page(:query, :integer, "page", required: true)
      page_size(:query, :integer, "page_size")
      distance_unit :query,  :array, "Distance unit", required: true,
      items: [type: :string, enum: ["km", "miles"]]
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  def nearby_recommendations(conn, params) do
    %{id: user_id} = user = Api.Guardian.Plug.current_resource(conn)
    params = if !params["page_size"], do: Map.put(params, "page_size", 10), else: params
    params = if is_nil(params["latitude"]) || is_nil(params["longitude"]) do
      geo = Data.Repo.get_by(Data.Schema.UserGeoLocation, user_id: user_id)
      params = Map.merge(params, %{"latitude" => geo && geo.latitude || user.latitude, "longitude" => geo && geo.longitude || user.longitude})
    else
      params
    end

    favorites = UserFavorites.get_near_by_favorites(user_id, params)
    render(conn, "nearby_recommendations.json", %{favorites: favorites})
  end

  #----------------------------------------------------------------------------
  # user_recommendations/2
  #----------------------------------------------------------------------------
  swagger_path :user_recommendations do
    get("/v1.0/user-recommendations")
    summary("Get all recommendations of a specific user")
    description("Get all recommendations of a specific user")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      user_id(:query, :string, "user_id", required: true)
      page(:query, :integer, "page", required: true)
      page_size(:query, :integer, "page size")
    end

    response(200, "Ok", Schema.ref(:UserFavorite))
  end

  def user_recommendations(conn, %{"user_id" => user_id, "page" => page} = params) do
    page_size = params["page_size"] || 10
    favorites = UserFavorites.get_user_recommendations(user_id, page, page_size)
    render(conn, "nearby_recommendations.json", %{favorites: favorites})
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      UserFavorite:
        swagger_schema do
          title("User Favourite")
          description("User Favourite")

          example(%{
              description: "This is a first description test",
              Address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
              user_favorite_type_id: "restaurant || city || activity",
              id: "d822b84d-a76a-446a-9daa-ab85fe537fea",
              image: "https://d1exz3ac7m20xz.cloudfront.net/images/user-profile-images/user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
              name: "hello",
              user_id: "user",
              latitude: "19.002",
              longitude: "0.22512"
          })
        end,
      CreateUserFavorite:
        swagger_schema do
          title("Create User Favourite")
          description("Create a User Favourite")

          properties do
            name(:string, "Name")
            description(:string, "Description of User Favourite")
            address(:string, "Address")
            user_favorite_type_id(:string, "User Favourite Type id")
            image(:string, "base64 image")
            latitude(:float, "Latitude")
            longitude(:float, "Longitude")
          end

          example(%{
              description: "This is a first description test",
              address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
              name: "Name",
              user_favorite_type_id: "restaurant || city || activity || site",
              image: "",
              latitude: "19.003",
              longitude: "0.000025"
          })
        end,
      UpdateUserFavorite:
              swagger_schema do
              title("Update User Favourite")
              description("Update User Favourite")

          properties do
                name(:string, "Name")
                description(:string, "Description of User Favourite")
                address(:string, "Address")
                image(:string, "base64 image")
                latitude(:float, "Latitude")
                longitude(:float, "Longitude")
          end

          example(%{
            description: "This is a first description test",
            address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
            name: "Name",
            image: "",
            latitude: "19.003",
            longitude: "0.000025"
          })
        end,
        RecommendationParams:
          swagger_schema do
            title("Params to ask for recommendations")
            description("Params to ask for recommendations")

            properties do
              type(:string, "Type of Recomendation")
              user_id(:string, "User id")
            end

            example(%{
              type: "city | restaurent | activity | site",
              user_id: "1117c852-2c35-4e93-a04a-fff41be35fdc"
            })
          end
    }
  end
end
