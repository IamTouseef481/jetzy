#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.GuestInterestController do
  @moduledoc """
  Manage Guest Account Interested (tied to user's device identifier)
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.GuestInterests
  alias Data.Schema.{GuestInterest}

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get "/v1.0/guest/guest-interest/{device_id}"
    summary "Get GuestInterest By ID"
    description "Get GuestInterest By ID"
    produces "application/json"
    parameters do
      device_id :path, :string, "Device ID", required: true
    end
    response 200, "Ok", Schema.ref(:GuestInterest)
  end
  @doc """
  Show interests for guest account associated with user's device id.
  """
  def show(conn, %{"id" => device_id}) do
    case GuestInterests.get_guest_interest_by_device_id(device_id) do
      guest_interests -> render(conn, "guest_interests.json", %{guest_interests: guest_interests})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post "/v1.0/guest/guest-interest"
    summary "Create GuestInterest"
    description "Create GuestInterest by adding correct user_id and role_id according to your case"
    produces "application/json"
    parameters do
      body :body, Schema.ref(:CreateGuestInterest), "Create GuestInterest params", required: true
    end
    response 200, "Ok", Schema.ref(:CreateGuestInterest)
  end
  @doc """
  Save list of interests for Guest user by Device Identifier.
  """
  def create(conn, %{"device_id" => device_id, "interest_list" => interest_list} = params) do
    device_id = String.trim(device_id)
    Enum.each(interest_list, fn %{"is_member" => is_member, "interest_id" => interest_id} ->
      interest_id = String.trim(interest_id)
      if is_member == true do
        case GuestInterests.get_guest_interest_by_device_and_interest_id(device_id, interest_id) do
          %GuestInterest{} -> nil
          nil ->
            params = %{"device_id" => device_id, "interest_id" => interest_id}
            case Context.create(GuestInterest, params) do
              {:ok, guest_interest} -> guest_interest
              {:error, %Ecto.Changeset{}} -> nil
              {:error, _} -> nil
            end
          {:error, _} -> nil
        end
      else
        case GuestInterests.get_guest_interest_by_device_and_interest_id(device_id, interest_id) do
          nil -> nil
          %GuestInterest{} = guest_interest -> Context.delete(guest_interest)
        end
      end
    end)
    render(conn, "save_guest_interest.json", %{guest_interest: params})
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      GuestInterest: swagger_schema do
                       title "GuestInterest"
                       description "GuestInterest"
                       example %{
                         ResponseData: [
                           "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
                           "41fe4093-5be0-434f-9db6-82ceb9f91948"
                         ]
                       }
                     end,
      CreateGuestInterest: swagger_schema do
                             title "Create GuestInterest"
                             description "Create GuestInterest"
                             properties do
                               interest_list(:array, "interest ids")
                               device_id :string, "Device ID"
                             end
                             example %{
                               device_id: "admin",
                               interest_list:
                                 [%{interest_id: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c", is_member: true},
                                 %{interest_id: "41fe4093-5be0-434f-9db6-82ceb9f91948", is_member: false}]
                             }
                           end
    }
  end
end
