#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Vocation.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use PhoenixSwagger

  #  use JetzyElixir.ApiBehaviour,
  #      entity_module: Jetzy.Vocation.Entity


  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/vocations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyVocationList)
  end
  def index(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/vocations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyVocation)
  end
  def show(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def create/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/vocations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyVocation)
  end
  def create(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/vocations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyVocation)
  end
  def update(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/vocations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyVocation)
  end
  def delete(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end


  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      JetzyVocation: swagger_schema do
                           title "Jetzy Vocation"
                           description "Jetzy Vocation"
                           example(
                             %{
                               identifier: 1,
                             })
                         end,
      JetzyVocationList: swagger_schema do
                               title "Jetzy Vocation List"
                               description "Jetzy Vocation List"
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