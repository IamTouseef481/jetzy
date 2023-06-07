#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Media.Image.Upload.Controller do
  use JetzyApi, :controller
  import JetzyWeb.Helpers
  # import Plug.Conn

  def show_version(conn, params) do
    context = default_get_context(conn, params)
    api_response(conn, %{wip: true}, context)
  end

  def rename(conn, params) do
    context = default_get_context(conn, params)
    response = %{}
    api_response(conn, response, context)
  end

  def resize(conn, params) do
    context = default_get_context(conn, params)
    response = %{}
    api_response(conn, response, context)
  end

  def set_main(conn, params) do
    context = default_get_context(conn, params)
    response = %{}
    api_response(conn, response, context)
  end

  def sort(conn, params) do
    context = default_get_context(conn, params)
    response = %{}
    api_response(conn, response, context)
  end

  #
  #
  #  def create(conn, params) do
  #    context = default_get_context(conn, params)
  #    case context.caller do
  #      {:ref, Jetzy.User.Entity, _} ->
  #        case conn.body_params do
  #          %{"files" => [%Plug.Upload{} = file]} ->
  #            upload = Jetzy.Image.Upload.Repo.from_upload(file, context.caller, context)
  #            response = Jetzy.Image.Upload.Entity.file_uploader_format(upload, context)
  #            api_response(conn, response, context)
  #        end
  #    end
  #  end
  #
  #  def update(conn, params) do
  #    context = default_get_context(conn, params)
  #    case conn.body_params do
  #      %{"files" => [%Plug.Upload{} = file]} ->
  #        case context.caller do
  #          {:ref, Jetzy.User.Entity, _} ->
  #            image =  Jetzy.Image.Upload.Entity.ref(params["id"])
  #            cond do
  #              image == nil -> api_response(conn, %{msg: "not found"}, context)
  #              Jetzy.Image.Upload.Entity.has_permission!(image, :delete, context) ->
  #                upload = Jetzy.Image.Upload.Repo.update_from_upload(params["id"], file, context)
  #                response = Jetzy.Image.Upload.Entity.file_uploader_format(upload, context)
  #                api_response(conn, response, context)
  #              true -> api_response(conn, %{msg: "not found"}, context)
  #            end
  #        end
  #    end
  #  end
  #
  #  def show(conn, params) do
  #    _context = default_get_context(conn, params)
  #    # Todo validations, error handling, alternative resolution/sizes.
  #    image = Jetzy.Image.Upload.Entity.entity!(params["id"])
  #    contents = File.read!(image.base)
  #    conn
  #    |> put_resp_content_type("application/#{image.file_format}")
  #    |> send_resp(200, contents)
  #  end
  #
  #  def delete(conn, params) do
  #    context = default_get_context(conn, params)
  #    case context.caller do
  #      {:ref, Jetzy.User.Entity, _} ->
  #        image =  Jetzy.Image.Upload.Entity.ref(params["id"])
  #        cond do
  #          image == nil -> api_response(conn, %{msg: "not found"}, context)
  #          Jetzy.Image.Upload.Entity.has_permission!(image, :delete, context) ->
  #            Jetzy.Image.Upload.Repo.delete!(image, context)
  #            api_response(conn, %{msg: "removed"}, context)
  #          true -> api_response(conn, %{msg: "not found"}, context)
  #        end
  #    end
  #  end


end

end