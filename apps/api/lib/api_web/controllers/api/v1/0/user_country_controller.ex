#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule ApiWeb.Api.V1_0.UserCountryController do
  @moduledoc """
  Manage user city/country locations.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.UserCountries
  alias Data.Schema.UserCountry

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/user-city")
    summary("Create User city")
    description("Save User City and return other cities of users")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateUserCity), "Create User City params", required: true)
    end

    response(200, "Ok", Schema.ref(:CreateUserCity))
  end

  @doc """
  Create a User City dynamically.
  """
  def create(conn, params) do

    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    params = Map.put(params, "user_id", user_id)
    user_country_date_map = %{
      "from_date" => Date.from_iso8601!(params["display_to_date"]),
      "to_date"=> Date.from_iso8601!(params["display_from_date"])
    }
    params = Map.merge(params, user_country_date_map)
    case Context.create(UserCountry, params) do
      {:error, error} ->
        render(conn, "user_country.json", %{error: error})

      {:ok, _user_country} ->
        user_countries = UserCountries.get_by_user_id(user_id)
        render(conn, "user_countries.json", %{user_countries: user_countries})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v1.0/user-city/{id}"
    summary "Delete User City"
    description "Delete User City"
    produces "application/json"
    security [%{Bearer: []}]

    parameters do
      id :path, :string, "User Country ID", required: true
    end

    response(200, "Ok", Schema.ref(:UserCountry))
  end

  @doc """
  Delete a User-City
  """
  def delete(conn, %{"id" => id} = _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    with %UserCountry{} = user_country <- Context.get(UserCountry, id),
         {:ok, %UserCountry{} = _user_country} <- Context.delete(user_country) do
      user_countries = UserCountries.get_by_user_id(user_id)
      render(conn, "user_countries.json", %{user_countries: user_countries})
    else
      nil -> render(conn, "user_country.json", %{error: ["User City not found"]})
      {:error, error} -> render(conn, "user_country.json", %{error: error})
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
      UserCountry: swagger_schema do
        title "User Country"
        description "User Country"
        example %{
          displayFromDate: "2019-01-01",
          country: "Spain",
          city: "Madrid",
          displayToDate: "2019-01-01"
       }
      end,
      CreateUserCity: swagger_schema do
        title "Save User City"
        description "Save User City"
        properties do
          displayFromDate :date, "displayFromDate"
          displayToDate :date, "displayToDate"
          city :string, "city"
          country :string, "country"
        end
        example %{
           displayFromDate: "2019-01-01",
           country: "Spain",
           city: "Madrid",
           displayToDate: "2019-01-01"
        }
      end
    }
  end
end
