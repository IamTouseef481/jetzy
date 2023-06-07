if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Referral.Controller do
  use JetzyApi, :controller
  use PhoenixSwagger

  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/referral-code"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCodeList)
  end
  def index(conn, params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        codes = Jetzy.User.Referral.Code.Repo.by_user(context.caller, context, [all: true])
        api_response(conn, %{outcome: true, codes: codes || []}, context, [])
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end

  #---------------------------------------
  # def generate_code/2
  #---------------------------------------
  swagger_path :generate_code do
    PhoenixSwagger.Path.put "/v2.0/referral-code/generate"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def generate_code(conn, params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        count = numeric_query_param("count", params, nil) || 5
        suggestions = Jetzy.User.Referral.Code.Repo.suggest(context.caller, context, [count: count])
        api_response(conn, %{outcome: true, values: suggestions}, context, [])
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end


  #---------------------------------------
  # def available/2
  #---------------------------------------
  swagger_path :available do
    PhoenixSwagger.Path.get "/v2.0/referral-code/{code}/available"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def available(conn, %{"code" => code} = params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        reserve = boolean_query_param("reserve", params)
        available = Jetzy.User.Referral.Code.Repo.code_available?(context.caller, code, context, [reserve: reserve])
        api_response(conn, %{outcome: true, available: available}, context, [])
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end

  #---------------------------------------
  # def register/2
  #---------------------------------------
  swagger_path :register do
    PhoenixSwagger.Path.put "/v2.0/referral-code/{code}/register"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def register(conn, %{"code" => code} = params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        weight = numeric_query_param("weight", params) || :os.system_time(:second)
        cond do
          registered = Jetzy.User.Referral.Code.Repo.register(context.caller, code, context, [weight: weight]) ->
            api_response(conn, %{outcome: true, registered: registered}, context, [])
          :else ->
            api_response(conn, %{outcome: false}, context, [])
        end
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end

  #---------------------------------------
  # def claim/2
  #---------------------------------------
  swagger_path :claim do
    PhoenixSwagger.Path.put "/v2.0/referral-code/{code}/claim"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def claim(conn, %{"code" => code} = params) do
    context = default_get_context(conn, params)
    case Jetzy.User.Referral.Code.Repo.claim(context.caller, code, context) do
      true -> api_response(conn, %{outcome: true}, context, [])
      {:error, reason} -> api_response(conn, %{outcome: false, message: "#{inspect reason}"}, context, [])
    end
  end

  #---------------------------------------
  # def referrals/2
  #---------------------------------------
  swagger_path :referrals do
    PhoenixSwagger.Path.get "/v2.0/referral-code/{code}/referrals"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralList)
  end
  def referrals(conn, %{"id" => code_sref} = params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        code = Jetzy.User.Referral.Code.Entity.entity!(code_sref)
        cond do
          code && code.user == context.caller ->
            page = numeric_query_param("pg", params, 1)
            rpp = numeric_query_param("rpp", params, 250)
            referrals = Jetzy.User.Referral.Code.Entity.referrals(code, context, [page: page, rpp: rpp])
            api_response(conn, %{outcome: true, values: referrals}, context, [])
          !code -> api_response(conn, %{outcome: false, message: "Not Found"}, context, [])
          :else ->
            conn
            |> put_status(403)
            |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
        end
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end

  #---------------------------------------
  # def enable_code/2
  #---------------------------------------
  swagger_path :enable_code do
    PhoenixSwagger.Path.put "/v2.0/referral-code/{code}/enable"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def enable_code(conn, %{"id" => code_sref} = params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        code = Jetzy.User.Referral.Code.Entity.entity!(code_sref)
        cond do
          code && code.user == context.caller ->
            code = Jetzy.User.Referral.Code.Entity.enable(code, context)
            api_response(conn, %{outcome: true, code: code}, context, [])
          !code -> api_response(conn, %{outcome: false, message: "Not Found"}, context, [])
          :else ->
            conn
            |> put_status(403)
            |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
        end
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
    end
  end

  #---------------------------------------
  # def disable_code/2
  #---------------------------------------
  swagger_path :disable_code do
    PhoenixSwagger.Path.put "/v2.0/referral-code/{code}/disable"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyReferralCode)
  end
  def disable_code(conn, %{"id" => code_sref} = params) do
    context = default_get_context(conn, params)
    case context.caller do
      {:ref, Jetzy.User.Entity, _} ->
        code = Jetzy.User.Referral.Code.Entity.entity!(code_sref)
        cond do
          code && code.user == context.caller ->
            code = Jetzy.User.Referral.Code.Entity.disable(code, context)
            api_response(conn, %{outcome: true, code: code}, context, [])
          !code -> api_response(conn, %{outcome: false, message: "Not Found"}, context, [])
          :else ->
            conn
            |> put_status(403)
            |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
        end
      _ ->
        conn
        |> put_status(403)
        |> api_response(%{outcome: false, message: "Access Denied"}, context, [])
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
      JetzyReferral: swagger_schema do
                   title "JetzyReferral"
                   description "JetzyReferral"
                   example(
                     %{
                       identifier: 1,
                     })
                 end,
      JetzyReferralList: swagger_schema do
                       title "JetzyReferral List"
                       description "JetzyReferral List"
                       example ([
                                  %{
                                    identifier: 1,
                                  }
                                ])
                     end,
      JetzyReferralCode: swagger_schema do
                       title "JetzyReferralCode"
                       description "JetzyReferralCode"
                       example(
                         %{
                           identifier: 1,
                         })
                     end,
      JetzyReferralCodeList: swagger_schema do
                           title "JetzyReferralCode List"
                           description "JetzyReferralCode List"
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