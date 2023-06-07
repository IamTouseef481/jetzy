#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Admin.User.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.User.Entity
  use PhoenixSwagger
  use Amnesia
  use JetzySchema.Database.User.Table
  alias JetzySchema.Database.User.Table, as: Table
  # import Plug.Conn


  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/admin/users"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserList)
  end
  def index(conn, params) do
    context = default_get_context(conn, params)
    #token = JetzyWeb.FirebaseGuardian.Plug.current_token(conn)
    #claims = JetzyWeb.FirebaseGuardian.Plug.current_claims(conn)
    #resource = JetzyWeb.FirebaseGuardian.Plug.current_resource(conn)
    {page, results_per_page} = request_pagination(params, 0, 100)
    results = Amnesia.async(fn -> page(page, Table.where(1 == 1, limit: results_per_page)) end)
              |> Enum.map(&(&1.entity))
    api_response(conn, %{results: results}, context)

    #if resource do
    # api_response(conn, %{users: [1,2,3,4,5]}, context)
    #else
    # conn
    # |> put_status(304)
    # |> api_response(%{msg: "Access Denied"}, context)
    #end
  end


  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/admin/users/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def show(conn, params), do: super(conn, params)


  #---------------------------------------
  # def creat/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/admin/users"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def create(conn, params), do: super(conn, params)


  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/admin/users/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def update(conn, params), do: super(conn, params)


  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/admin/users/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def delete(conn, params), do: super(conn, params)



end

end