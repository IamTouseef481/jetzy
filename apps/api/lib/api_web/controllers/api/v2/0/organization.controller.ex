#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Organization.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  #  use JetzyElixir.ApiBehaviour,
  #      entity_module: Jetzy.Organization.Entity
  use PhoenixSwagger

  #  use JetzyElixir.ApiBehaviour,
  #      entity_module: Jetzy.Organization.Entity


  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/organizations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyOrganizationList)
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
    PhoenixSwagger.Path.get "/v2.0/organizations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyOrganization)
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
    PhoenixSwagger.Path.post "/v2.0/organizations"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyOrganization)
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
    PhoenixSwagger.Path.put "/v2.0/organizations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyOrganization)
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
    PhoenixSwagger.Path.delete "/v2.0/organizations/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyOrganization)
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
      JetzyOrganization: swagger_schema do
                           title "Jetzy Organization"
                           description "Jetzy Organization"
                           example(
                             %{
                               identifier: 1,
                             })
                         end,
      JetzyOrganizationList: swagger_schema do
                               title "Jetzy Organization List"
                               description "Jetzy Organization List"
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