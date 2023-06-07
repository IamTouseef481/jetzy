#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Media.Image.Controller do
  use JetzyApi, :controller
  import JetzyWeb.Helpers
  import Plug.Conn


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
    _context = default_get_context(conn, params)
    # Todo validations, error handling, alternative resolution/sizes.
    image = Jetzy.Image.Entity.entity!(params["id"])
    if image do
      contents = File.read!(image.base)
      conn
      |> put_resp_content_type("application/#{image.file_format}")
      |> send_resp(200, contents)
    end

  end

  def delete(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

end

end