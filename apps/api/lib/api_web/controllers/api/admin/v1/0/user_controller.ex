#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.Admin.V1_0.UserController do
  @moduledoc """
  Jetzy Admin Api Controller.
  """
  
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  require Logger
  import Ecto.Query, warn: false
  
  import JetzyWeb.Helpers.Records.ApiResponse
  import JetzyWeb.Helpers.Records.StatusField





  @enum_white_list %{
    boolean: %{"null" => nil, "false" => false, "true" => true},
    user_level: %{"pending" => :pending, "unverified" => :unverified, "verified" => :verified, "exclusive" => :exclusive, "staff" => :staff,},
    influencer_level: %{"none" => :none, "basic" => :basic, "standard" => :standard, "celebrity" => :celebrity,},
    permission_level: %{"approved" => :approved, "pending" => :pending, "paused" => :paused, "denied" => :denied, "review" => :review}
  }
  @enum_white_list_msg Enum.map(@enum_white_list, fn({k,v}) -> {k, Map.keys(v)} end) |> Map.new()
  @user_status_fields %{
    "jetzy-select" => status_field(field: :jetzy_select_status, white_list: :permission_level),
    "jetzy-exclusive" => status_field(field: :jetzy_exlusive_status, white_list: :permission_level),
    "is-active" => status_field(field: :is_active, white_list: :boolean),
    "is-deleted" => status_field(field: :is_deleted, white_list: :boolean),
    "is-deactivated" => status_field(field: :is_deactivated, white_list: :boolean),
    "is-self-deactivated" => status_field(field: :is_self_deactivated, white_list: :boolean),
    "is-referral" => status_field(field: :is_referral, white_list: :boolean),
    "user-level" => status_field(field: :user_level, white_list: :user_level),
    "influencer-level" => status_field(field: :influencer_level, white_list: :influencer_level),
  }

  @api_response_error %{
    invalid: %{
      status: %{
        field: api_response(status: 406, code: 1000, message: "Invalid user status field. Allowed values: #{inspect Map.keys(@user_status_fields)}"),
        value: %{
          permission_level: api_response(status: 406, code: 1002, message: "Invalid Permission Level: Allowed values: #{inspect Map.keys(@enum_white_list.permission_level)}"),
          boolean: api_response(status: 406, code: 1003, message: "Invalid Boolean: Allowed values: #{inspect Map.keys(@enum_white_list.boolean)}"),
          influencer_level: api_response(status: 406, code: 1004, message: "Invalid Influencer Level: Allowed values: #{inspect Map.keys(@enum_white_list.influencer_level)}"),
          user_level: api_response(status: 406, code: 1005, message: "Invalid Permission Level: Allowed values: #{inspect Map.keys(@enum_white_list.user_level)}"),
        }
      },
      user_list: api_response(status: 406, code: 1001, message: "Invalid user list field. Must be a list of valid user uuids."),
    },
    unknown: api_response(status: 500, code: 500, message: "Internal Error"),
  }
  
  #============================================================================
  # Controller Actions
  #============================================================================
  
  #----------------------------------------------------------------------------
  # set_user_status
  #----------------------------------------------------------------------------
  swagger_path :set_user_status do
    put "/v1.0/admin/users/status"
    summary "Bulk set user status field"
    description "Bulk set user status field"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      status :body, :string, "Status Field To Update: #{inspect Map.keys(@user_status_fields)}"
      value :body, :string, "Target Status: #{inspect @enum_white_list_msg}"
      users :body, Schema.ref(:GuidSet), "List of users to set to status_type field to status"
      remark :body, :string, "Update Reason"
    end
    response 200, "Ok", Schema.ref(:UpdateGuidSetResponse)
  end
  def set_user_status(conn, params) do
    %{"status" => status, "value" => value} = conn.body_params |> IO.inspect
    %Data.Schema.User{} = admin_user = Guardian.Plug.current_resource(conn)
    response = case @user_status_fields[status] do
      status_field(field: field, white_list: white_list) ->
        cond do
          set_to = @enum_white_list[white_list][value] ->
            users = conn.body_params["users"]
            cond do
              !is_list(users) -> @api_response_error.invalid.user_list
              length(users) == 0 -> @api_response_error.invalid.user_list
              :else ->
                users = Enum.uniq(users)
                query = from u in Data.Schema.User,
                             where: u.id in ^users
                with {_count, nil} <- Data.Repo.update_all(query, set: [{field, set_to}]) do
                  updated = Data.Repo.all(query)
                  updated_guids = updated |> Enum.map(&(&1.id))
                  if field == :jetzy_exclusive_status do
                    remark = conn.body_params["remark"]
                    spawn fn -> Enum.map(updated, &(Data.Context.UserApprovalLogs.record(&1, set_to, :admin, admin_user, remark))) end
                  end
                  spawn fn ->
                    Enum.map(updated_guids, fn(guid) ->
                      try do
                        ApiWeb.Endpoint.broadcast("backend:#{guid}", "refresh-cache", %{subject: "active-user"})
                      rescue _ -> :error
                      catch
                        :exit, _ -> :error
                        _ -> :error
                      end
                    end)
                  end
                  api_response(response: updated_guids)
                else
                  e ->
                    Logger.error("[ADMIN] Update Status Error: #{inspect e}")
                    @api_response_error.unknown
                end
            end
          :else -> @api_response_error.unknown.invalid.status.value[white_list]
        end
      _ -> @api_response_error.unknown.invalid.status.field
    end
    api_response_send(conn, response || @api_response_error.unknown)
  end
  
  #----------------------------------------------------------------------------
  # user_verification_request/2
  #----------------------------------------------------------------------------
  swagger_path :user_verification_request do
    get("/v1.0/admin/users/{user}/user-verification-request")
    summary("Get User Verification Request")
    description("Extra details to help with vetting users")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:VerificationRequest))
  end
  @doc """
  Get verification request object.
  @todo move logic into Context Class to keep code dry
  """
  def user_verification_request(conn, %{"user" => user_id} = params) do
    with %{id: _} = _current_user <- Guardian.Plug.current_resource(conn) do
      cond do
        existing = Data.Repo.get_by(DataSchema.UserVerificationRequest, user_id: user_id) ->
          conn
          render("verification_request.json", [admin: true, request: existing])
        :else ->
          conn
          |> put_status(404)
          |> json(%{success: false, message: "Not Found"})
      end
    else
    _ ->
      conn
      |> put_status(403)
      |> json(%{success: false, message: "Invalid Request"})
    end
  end

  #----------------------------------------------------------------------------
  # update_user_verification_request/2
  #----------------------------------------------------------------------------
  swagger_path :update_user_verification_request do
    put("/v1.0/admin/users/{user}/user-verification-request")
    summary("Update User Verification Request")
    description("Extra details to help with vetting users")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:VerificationRequest))
  end
  @doc """
  Update verification request object.
  @todo move logic into Context Class to keep code dry
  """
  def update_user_verification_request(conn, %{"user" => user_id} = params) do
    with %{id: _} = _current_user <- Guardian.Plug.current_resource(conn) do
      cond do
        existing = Data.Repo.get_by(Data.Schema.UserVerificationRequest, user_id: user_id) ->
          now = DateTime.utc_now()
          record = conn.body_params
                   |> SecureX.Helper.keys_to_atoms()
                   |> update_in([:updated_at], &(&1 || now))
          record = (if Map.has_key?(record, :email_preference) do
                      record
                      |> update_in([:email_preference], &(&1 && String.to_existing_atom(&1)))
                    else
                      record
                    end)
          record = (if Map.has_key?(record, :approval_status) do
                      record
                      |> update_in([:approval_status], &(&1 && String.to_existing_atom(&1)))
                    else
                      record
                    end)
          with {:ok, record} <- Data.Context.update(Data.Schema.UserVerificationRequest, existing, record) do
            conn
            render("verification_request.json", [admin: true, request: record])
          else
            _ ->
              conn
              |> put_status(403)
              |> json(%{success: false, code: :update_failed, message: "Update Failed"})
          end
        :else ->
          now = DateTime.utc_now()
          record = conn.body_params
                   |> SecureX.Helper.keys_to_atoms()
                   |> put_in([:approval_status], :pending)
                   |> put_in([:inserted_at], now)
                   |> update_in([:updated_at], &(&1 || now))
                   |> update_in([:email_preference], &(&1 && String.to_existing_atom(&1) || :in_app))
          with {:ok, record} <- Data.Context.create(Data.Schema.UserVerificationRequest, record) do
            conn
            render("verification_request.json", [admin: true, request: record])
          else
            _ ->
              conn
              |> put_status(403)
              |> json(%{success: false, code: :update_failed, message: "Update Failed"})
          end
      end
    else
      _ ->
        conn
        |> put_status(403)
        |> json(%{success: false, code: :auth_error, message: "Invalid Request"})
    end
  end

  
  def api_response_send(conn, api_response(status: status, code: code, message: message, response: response)) do
    conn
    |> put_status(status)
    |> json(%{code: code, message: message, response: response})
  end


  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  @todo Do these definitions need to be inline or can we prepare a master list of common elements that are exposed by multiple apis and inject here? - kebrings
  """
  def swagger_definitions do
    %{
      GuidSet: swagger_schema do
                 title "List of db guids"
                 description "List of db guids"
                 example ["0000-0000-0000-0000"]
               end,
      UpdateGuidSetResponse: swagger_schema do
                               title "List of updated guids"
                               description "List of updated guids"
                               example %{
                                 code: 200,
                                 records: ["0000-0000-0000-0000"]
                               }
                             end,
      VerificationRequest:
        swagger_schema do
          title("Verification Request")
          description("User SignUp/Verification Request")

          example(%{
            responseData: %{}
          })
        end,
    }
  end
  
  
  
  
end
