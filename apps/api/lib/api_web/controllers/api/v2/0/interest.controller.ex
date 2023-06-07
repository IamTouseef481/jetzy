#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Interest.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.Interest.Entity

  use PhoenixSwagger


  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/interests"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyInterestList)
  end
  def index(conn, params), do: super(conn, params)

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/interests/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyInterest)
  end
  def show(conn, params), do: super(conn, params)


  #---------------------------------------
  # def create/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/interests"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyInterest)
  end
  def create(conn, params), do: super(conn, params)


  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/interests/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyInterest)
  end
  def update(conn, params), do: super(conn, params)


  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/interests/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyInterest)
  end
  def delete(conn, params), do: super(conn, params)



  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      JetzyInterest: swagger_schema do
                    title "Interest"
                    description "Interest"
                    example(
                      %{
                        identifier: 1,
                      })
                  end,
      JetzyInterestList: swagger_schema do
                        title "Interests"
                        description "Interest List"
                        example ([
                                   %{
                                     identifier: 1,
                                   }
                                 ])
                      end

    }
  end

end

end