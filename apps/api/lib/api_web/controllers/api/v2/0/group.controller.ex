#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Group.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.Group.Entity
  use PhoenixSwagger


  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/groups"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyGroupList)
  end
  def index(conn, params), do: super(conn, params)

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/groups/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyGroup)
  end
  def show(conn, params), do: super(conn, params)


  #---------------------------------------
  # def create/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/groups"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyGroup)
  end
  def create(conn, params), do: super(conn, params)


  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/groups/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyGroup)
  end
  def update(conn, params), do: super(conn, params)


  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/groups/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyGroup)
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
      JetzyGroup: swagger_schema do
                       title "Jetzy Group"
                       description "Jetzy Group"
                       example(
                         %{
                           identifier: 1,
                         })
                     end,
      JetzyGroupList: swagger_schema do
                           title "Jetzy Group List"
                           description "Jetzy Group List"
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