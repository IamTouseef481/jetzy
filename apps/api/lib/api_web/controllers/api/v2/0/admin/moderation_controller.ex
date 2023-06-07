#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Admin.Moderation.Controller do
  use JetzyApi, :controller
  use Amnesia
  use PhoenixSwagger
  #use JetzySchema.Database.Moderation.Report.Table
  #alias JetzySchema.Database.Moderation.Report.Table, as: Table
  import JetzyWeb.Helpers

  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/admin/moderation"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyModerationList)
  end
  def index(conn, params) do
    context = default_get_context(conn, params)
    #    {page, results_per_page} = request_pagination(params, 0, 100)
    #    results = Amnesia.async(fn -> page(page, Table.where(1 == 1, limit: results_per_page)) end)
    #              |> Enum.map(&(&1.entity))
    api_response(conn, %{wip: true}, context)
  end

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/admin/moderation/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyModeration)
  end
  def show(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/admin/moderation/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyModeration)
  end
  def update(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end


  #---------------------------------------
  # def create/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/admin/moderation"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyModeration)
  end
  def create(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/admin/moderation/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyModeration)
  end
  def delete(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      JetzyModeration: swagger_schema do
                     title "JetzyModeration"
                     description "JetzyModeration Entity"
                     example (
                                %{
                                  identifier: 1,
                                }
                              )
                   end,
      JetzyModerationList: swagger_schema do
                    title "Jetzy Moderation List"
                    description "list of Moderation entities"
                    example(
                      [%{
                        identifier: 1,
                      }])
                  end
    }
  end
end

end