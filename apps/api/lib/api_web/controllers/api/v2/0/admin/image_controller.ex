#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Admin.Image.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.Image.Entity
  use PhoenixSwagger
  use Amnesia
  use JetzySchema.Database.Image.Table
  alias JetzySchema.Database.Image.Table, as: Table

  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/admin/images"
    summary "Admin List Images"
    description "Get list of images."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyImageList)
  end
  def index(conn, params) do
    context = default_get_context(conn, params)
    {page, results_per_page} = request_pagination(params, 0, 100)
    results = Amnesia.async(fn -> page(page, Table.where(1 == 1, limit: results_per_page)) end)
              |> Enum.map(&(&1.entity))
    api_response(conn, %{results: results}, context)
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
    }
  end

end

end