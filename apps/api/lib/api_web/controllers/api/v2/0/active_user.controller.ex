
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.ActiveUser.Controller do
  use JetzyApi, :controller
  use PhoenixSwagger

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/active-user"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def show(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{caller: context.caller}, Noizu.ElixirCore.CallingContext.admin())
  end

  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/active-user"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUser)
  end
  def update(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def index_settings/2
  #---------------------------------------
  swagger_path :index_settings do
    PhoenixSwagger.Path.get "/v2.0/active-user/settings"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserSettings)
  end
  def get_settings(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def update_settings/2
  #---------------------------------------
  swagger_path :update_settings do
    PhoenixSwagger.Path.put "/v2.0/active-user/settings"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserSettings)
  end
  def update_settings(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def get_setting/2
  #---------------------------------------
  swagger_path :get_setting do
    PhoenixSwagger.Path.get "/v2.0/active-user/settings/{setting}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserSettings)
  end
  def get_setting(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def update_setting/2
  #---------------------------------------
  swagger_path :update_setting do
    PhoenixSwagger.Path.put "/v2.0/active-user/settings/{setting}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserSettings)
  end
  def update_setting(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def get_followers/2
  #---------------------------------------
  swagger_path :get_followers do
    PhoenixSwagger.Path.get "/v2.0/active-user/followers"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserList)
  end
  def get_followers(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end


  #---------------------------------------
  # def get_follows/2
  #---------------------------------------
  swagger_path :get_follows do
    PhoenixSwagger.Path.get "/v2.0/active-user/follows"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserList)
  end
  def get_follows(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  #---------------------------------------
  # def blocked_users/2
  #---------------------------------------
  swagger_path :blocked_users do
    PhoenixSwagger.Path.get "/v2.0/active-user/blocked-users"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyUserList)
  end
  def blocked_users(conn, params) do
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
      JetzyUserSetting: swagger_schema do
                         title "Jetzy User Setting"
                         description "Setting Entry"
                         example (
                                   %{
                                     identifier: 1,
                                   }
                                   )
                       end,
      JetzyUserSettings: swagger_schema do
                             title "Jetzy User Setting List"
                             description "list of Settings entities"
                             example(
                               [%{
                                 identifier: 1,
                               }])
                           end
    }
  end
end

end