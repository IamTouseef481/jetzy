#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Reaction.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  #
  #  def set_reaction(conn, %{"subject" => subject, "reaction" => reaction} = params) do
  #    context = default_get_context(conn, params)
  #    subject = Noizu.ERP.ref(subject)
  #    reaction = Jetzy.Repo.json_to_atom(:reaction, reaction)
  #
  #    case subject && reaction && context && context.caller do
  #      user = {:ref, Jetzy.User.Entity, _} ->
  #        results = Jetzy.Entity.InteractionsCache.Repo.record_interaction(subject, user, reaction, context)
  #        api_response(conn, results, context)
  #      _ ->
  #        conn
  #        |> put_status(403)
  #        |> api_response(conn, %{outcome: false, error: true}, context)
  #    end
  #  end
  #
  #  def remove_reaction(conn, %{"subject" => subject, "reaction" => reaction} = params) do
  #    context = default_get_context(conn, params)
  #    subject = Noizu.ERP.ref(subject)
  #    reaction = Jetzy.Repo.json_to_atom(:reaction, reaction)
  #
  #    case subject && reaction && context && context.caller do
  #      user = {:ref, Jetzy.User.Entity, _} ->
  #        results = Jetzy.Entity.InteractionsCache.Repo.remove_interaction(subject, user, reaction, context)
  #        api_response(conn, results, context)
  #      _ ->
  #        conn
  #        |> put_status(403)
  #        |> api_response(conn, %{outcome: false, error: true}, context)
  #    end
  #  end
end

end