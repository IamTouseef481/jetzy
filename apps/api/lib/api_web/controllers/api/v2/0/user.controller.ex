#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.User.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.User.Entity
  use PhoenixSwagger


  def reauthenticate(conn, params) do
    context = context(conn, params)
    claims = JetzyWeb.FirebaseGuardian.Plug.current_claims(conn)
    case Jetzy.User.Session.Repo.by_claim(claims) do
      %{__struct__: Jetzy.User.Session.Entity} = session ->
        case JetzyWeb.FirebaseGuardian.encode_and_sign(session, %{typ: "access", sref: Noizu.ERP.sref(session), aud: "jetzy"}) do
          {:ok, jwt, _claims} ->
            conn
            |> api_response(%{authenticated: true, jwt: jwt}, context)
          _ ->
            api_response(conn, %{authenticated: false, message: "Incorrect Login"}, context)
        end
      _ -> api_response(conn, %{authenticated: false, message: "Incorrect Login"}, context)
    end
  end

  def logout(conn, params) do
    context = context(conn, params)
    claims = JetzyWeb.FirebaseGuardian.Plug.current_claims(conn)
    case Jetzy.User.Session.Repo.by_claim(claims) do
      %{__struct__: Jetzy.User.Session.Entity} = session ->
        Jetzy.User.Session.Repo.delete!(session, Noizu.ElixirCore.CallingContext.system(context))
      _ -> nil
    end
    api_response(conn, %{action: :complete}, context)
  end

  def authenticate(conn, params) do
    context = default_get_context(conn, params)
    if conn.body_params["login"] && conn.body_params["password"] && conn.body_params["login"] != "" && conn.body_params["password"] != "" do
      case JetzyModule.AuthenticationModule.authenticate!(conn, :login_or_legacy, params, []) do
        {:authorized, session, conn} ->
          case JetzyWeb.FirebaseGuardian.encode_and_sign(session, %{typ: "access", sref: Noizu.ERP.sref(session), aud: "jetzy"}) do
            {:ok, jwt, _claims} ->
              # legacy hack, this would be incorrect for vnext authentication
              legacy = Jetzy.User.Credential.JetzyLegacy.mssql_hash_password(String.trim(conn.body_params["password"]))
              conn
              |> api_response(%{authenticated: true, jwt: jwt, legacy_token: legacy, user: Jetzy.User.Entity.entity!(session.user)}, context)
            _ ->
              api_response(conn, %{authenticated: false, message: "Invalid Login"}, context)
          end
      end
    else
      api_response(conn, %{authenticated: false, message: "Missing Username/Password"}, context)
    end
  end


  def follow_user(conn, params) do
    context = context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  def unfollow_user(conn, params) do
    context = context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  def block_user(conn, params) do
    context = default_get_context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  def unblock_user(conn, params) do
    context = context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  def silence_user(conn, params) do
    context = context(conn, params)
    results = %{} # WIP
    api_response(conn, results, context)
  end

  def unsilence_user(conn, params) do
    context = context(conn, params)
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
      JetzyUser: swagger_schema do
                    title "User"
                    description "User"
                    example(
                      %{
                        identifier: 1,
                      })
                  end,
      JetzyUserList: swagger_schema do
                        title "User List"
                        description "User List"
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