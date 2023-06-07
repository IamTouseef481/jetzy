#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Media.Video.Controller do
  use JetzyApi, :controller
  import JetzyWeb.Helpers


  def show_version(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  def create(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  def update(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  def show(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  def delete(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

end

end