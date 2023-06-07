#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.Admin.V1_0.AdminSelectController do
  @moduledoc false
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use PhoenixSwagger
  import JetzyWeb.Helpers
  
  alias Data.Context
  alias Data.Repo
  alias ApiWeb.Utils.Common
  use Filterable.Phoenix.Controller
  import Ecto.Query, warn: false
  alias Data.Context.{UserRewardTransactions, RewardOffers}
  alias Data.Schema.{RewardOffer, UserRewardTransaction, RewardManager, RewardImage, RewardTier}
  alias ApiWeb.Api.V1_0.RewardOfferView
  alias JetzyModule.AssetStoreModule
  alias Data.Context
  require Noizu.ElixirCore.Guards
  import Noizu.ElixirCore.Guards
  
  def access_denied_response(conn, context) do
    conn
    |> put_status(304)
    |> api_response(%{outcome: false, error: "Access Denied"}, context)
  end
  
  #============================================================================
  # Controller Actions
  #============================================================================
  swagger_path :grant_select do
    put("/v1.0/admin/user/{user}/select/subscription/grant")
    summary("Gift 12 Month Select")
    description("Gift 12 Month Select")
    produces("application/json")
    security([%{Bearer: []}])
  
    parameters do
      user(:query, :string, "ref-string", required: true)
    end
    response(200, "Ok", Schema.ref(:Outcome))
  end
  def grant_select(conn, params = %{"user" => user}) do
    context = JetzyWeb.Helpers.default_get_context(conn, params, [])
    cond do
      is_admin_caller(context) ->
        with {:ok, user} <- Data.Schema.User.entity_ok!(user) do
          Data.Repo.update(Data.Schema.User.upsert_changeset(user, %{jetzy_select_status: :approved}))
          email? = case conn.query_params["email"] do
                     "true" -> true
                     _ -> false
                   end
          with {:ok, user_entity} <- Jetzy.User.Entity.entity_ok!(user.id) do
            Jetzy.Subscription.Repo.add_trial(user_entity, "select-standard", context, [welcome_email: email?, period: [months: 12]])
          end
          
          api_response(conn, %{outcome: true, message: nil, entity: nil}, context)
        else
          _ ->
            conn
            |> put_status(405)
            |> api_response(%{outcome: false, message: "User Not Found", entity: nil}, context)
        end
      :else -> access_denied_response(conn, context)
    end
  end
  
  #----------------------------------------------------------------------------
  # approve_sign_up/2
  #----------------------------------------------------------------------------
  swagger_path :approve_sign_up do
    get("/v1.0/admin/select/sign-ups/{id}/approve")
    summary("Approve SignUp")
    description("Approve SignUp")
    produces("application/json")
    security([%{Bearer: []}])
    
    parameters do
      id(:query, :string, "id", required: true)
    end
    response(200, "Ok", Schema.ref(:Outcome))
  end
  @doc """
  Get list of reward offers for active user.
  """
  def approve_sign_up(conn, %{"id" => id} = params) do
    context = JetzyWeb.Helpers.default_get_context(conn, params, [])
    cond do
      is_admin_caller(context) ->
        if approved = Jetzy.Select.SignUp.Entity.approve(id, context) do
          if approved.user do
            try do
              user_id = Jetzy.User.Entity.universal_identifier(approved.user)
              ApiWeb.Endpoint.broadcast("backend:#{user_id}", "refresh-cache", %{subject: "active-user"})
            rescue _ -> :error
            catch
              :exit, _ -> :error
              _ -> :error
            end
          end
          api_response(conn, %{outcome: true, entity: approved}, context)
        else
          api_response(conn, %{outcome: false, entity: nil}, context)
        end
      :else -> access_denied_response(conn, context)
    end
  end
  
  #----------------------------------------------------------------------------
  # index_sign_ups/2
  #----------------------------------------------------------------------------
  swagger_path :index_sign_ups do
    get("/v1.0/admin/select/sign-ups")
    summary("List Sign Ups")
    description("List Sign Ups")
    produces("application/json")
    security([%{Bearer: []}])
    
    parameters do
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
    end
    response(200, "Ok", Schema.ref(:ListSignUps))
  end
  @doc """
  Get list of reward offers for active user.
  """
  def index_sign_ups(conn, %{"page" => page} = params) do
    context = context = JetzyWeb.Helpers.default_get_context(conn, params, [])
    cond do
      is_admin_caller(context) ->
        page_size = params["page_size"] || 20
        case Jetzy.Select.SignUp.Repo.list!(%{page: page, rpp: page_size}, [], Noizu.ElixirCore.CallingContext.system(), []) do
          repo = %{entities: l} ->
            paginated = Jetzy.Select.SignUp.Repo.pagination_format(repo)
            api_response(conn, paginated, context)
          _ ->
            conn
            |> put_status(304)
            |> api_response(%{outcome: false, error: "Internal Error"}, context)
        end
      :else -> access_denied_response(conn, context)
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
      ListSignUps:
        swagger_schema do
          title("List Select SignUps")
          description("List Select SignUps")
          example(%{
            pagination: %{
              total_pages: 2,
              page: 1,
              total_rows: 10
            },
            data: [
              %{
              },
              %{
              }
            ]
          })
        end,
      Outcome:
        swagger_schema do
          title("Request Outcome")
          description("Request Outcome")
          example(%{
            outcome: true,
            entity: %{},
            message: nil,
          })
        end,
    }
  end
end
