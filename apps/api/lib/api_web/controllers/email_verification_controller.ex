#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.EmailVerificationController do
  @moduledoc """
  Manage Email Verification Flow.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  require Logger
#  alias Data.Context
#  alias Data.Schema.User

  #============================================================================
  # Controller Actions
  #============================================================================
  def welcome(conn, params) do
    render(conn, "welcome.html", %{message: "Welcome"})
  end

  def delete(conn, params) do
    token_key = conn.query_params["u"]
    with {:ok, token} <-  Noizu.SmartToken.V3.Token.Repo.authorize!(token_key, conn, Noizu.ElixirCore.CallingContext.system()),
         {:user, {:ref, Data.Schema.User, user_id}} <- token.resource,
         %{delete: :grant} <- token.permissions do
    
      with  %Data.Schema.User{} = user <- Data.Repo.get(Data.Schema.User, user_id),
            {:ok, user} <- Data.Context.update(Data.Schema.User, user, %{is_deleted: true, deleted_at: DateTime.utc_now()}) do
        # todo clear permission on token, or erase token.
        render(conn, "delete.html", %{token_key: token_key, message: "Your Account Has Been Flagged for Deletion. Your public data will be fully removed from the system in the next 7 business days."})
      else
        e ->
          Logger.error("#{inspect e}", label: "[ACCOUNT DELETE]")
          render(conn, "delete_invalid_token.html", %{token_key: token_key, message: "Apologies we are unable to flag your account for deletion due to an invalid authorization token. Please contact support to proceed"})
      end
    else
      e ->
        Logger.error("#{inspect e}", label: "[ACCOUNT DELETE]")
        render(conn, "delete_invalid_token.html", %{token_key: token_key, message: "Apologies we are unable to flag your account for deletion due to an invalid authorization token. Please contact support to proceed"})
    end
  end
  
  def confirm_delete(conn, params) do
    token_key = conn.query_params["u"]
    with {:ok, token} <-  Noizu.SmartToken.V3.Token.Repo.authorize!(token_key, conn, Noizu.ElixirCore.CallingContext.system()) do
      render(conn, "confirm_delete.html", %{message: "..."})
    else
      e ->
        Logger.error("#{inspect e}", label: "[ACCOUNT DELETE]")
        render(conn, "delete_invalid_token.html", %{token_key: token_key, message: "Apologies we are unable to flag your account for deletion due to an invalid authorization token. Please contact support to proceed"})
    end
  end
end
