#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule JetzyElixir.ApiBehaviour.Default do

  alias Noizu.ElixirCore.CallingContext
  require Logger
  #----------------------------
    # request_subject/4
    #----------------------------
    def request_subject(m, _conn, %{"identifier" => identifier} = _params, _options), do: m.entity_module().ref(identifier)
    def request_subject(m, _conn, %{"id" => identifier} = _params, _options) do
      m.entity_module().ref(identifier)
    end

    #----------------------------
    # context/4
    #----------------------------
    def context(_m, conn, params, options), do: JetzyWeb.Helpers.default_get_context(conn, params, options)


    #----------------------------
    # query_pagination/4
    #----------------------------
    def query_pagination(m, _conn, params, _options) do
      rpp = case params["rpp"] do
              v when is_bitstring(v) ->
                case Integer.parse(v) do
                  {rpp, _} -> rpp
                  _ -> m.default_pagination_size()
                end
              _ -> m.default_pagination_size()
            end

      pg = case params["pg"] do
             v when is_bitstring(v) ->
               case Integer.parse(v) do
                 {pg, _} -> pg
                 _ -> 0
               end
             _ -> 0
           end
      %{rpp: rpp, pg: pg}
    end

    #----------------------------
    # query_options/4
    #----------------------------
    def query_options(_m, _conn, _params, _options) do
      %{}
    end

    #==========================================
    # API CRUD Actions
    #==========================================
    def index(m, conn, params) do
      repo_module = m.repo_module()
      {query_options, context} = context_and_query_options(m, conn, params)
      pagination = m.query_pagination(conn, params)
      if m.repo_module().has_permission!(:index, context) do
        case m.repo_module().list!(pagination, query_options, context) do
          v = %{__struct__: ^repo_module} ->
            #-------------------------------------------------
            # @todo continuations, pagination details, etc.
            #-------------------------------------------------
            conn
            |> JetzyWeb.Helpers.api_response(v, context)
          _ ->
            conn
            |> Plug.Conn.put_status(400)
            |> JetzyWeb.Helpers.api_response(nil, context, query_options)
        end
      else
        access_denied(m, conn, context, query_options)
      end
    end

    def show(m, conn, params) do
      {query_options, context} = context_and_query_options(m, conn, params)
      Logger.info "SHOW: #{inspect m.request_subject(conn, params)}"
      cond do
        subject = m.request_subject(conn, params) ->
          if m.entity_module().has_permission!(subject, :show, context, query_options) do
            if entity = m.repo_module().get!(m.entity_module().id(subject), context, query_options) do
              conn
              |> JetzyWeb.Helpers.api_response(%{record: entity}, context, query_options)
            else
              conn
              |> Plug.Conn.put_status(404)
              |> JetzyWeb.Helpers.api_response(%{error: "Entity Not Found"}, context, query_options)
            end
          else
            access_denied(m, conn, context, query_options)
          end
        :invalid ->
          conn
          |> Plug.Conn.put_status(401)
          |> JetzyWeb.Helpers.api_response(%{error: "Invalid Identifier"}, context, query_options)
      end
    end

    def create(m, conn, params) do
      {query_options, context} = context_and_query_options(m, conn, params)
      entity = m.repo_module().from_json(conn.body_params, context, query_options)

      cond do
        entity == nil ->
          conn
          |> Plug.Conn.put_status(401)
          |> JetzyWeb.Helpers.api_response(%{error: "Invalid Request"}, context, query_options)

        m.entity_module().has_permission!(entity, :create, context, query_options) ->
          entity = m.repo_module().create!(entity, context, query_options)
          if entity do
            conn
            |> JetzyWeb.Helpers.api_response(%{record: entity}, context, query_options)
          else
            conn
            |> Plug.Conn.put_status(301)
            |> JetzyWeb.Helpers.api_response(%{error: "Internal Error"}, context, query_options)
          end

        :access_denied ->
          access_denied(m, conn, context, query_options)
      end
    end

    def edit(m, conn, params) do
      {query_options, context} = context_and_query_options(m, conn, params)
      subject = m.request_subject(conn, params)
      update = m.repo_module().from_json(conn.body_params, context, query_options)

      cond do
        update == nil || subject == nil ->
          conn
          |> Plug.Conn.put_status(401)
          |> JetzyWeb.Helpers.api_response(%{error: "Invalid Request"}, context, query_options)

        m.entity_module().ref(update) != subject ->
          conn
          |> Plug.Conn.put_status(401)
          |> JetzyWeb.Helpers.api_response(%{error: "Invalid Request"}, context, query_options)

        m.entity_module().has_permission!(update, :edit, context, query_options) ->
          entity = m.repo_module().get!(update.identifier, context, query_options)
          if entity do
            updated_entity = update
                             |> m.repo_module().merge!(entity, context, query_options)
                             |> m.repo_module().update!(context, query_options)
            conn
            |> JetzyWeb.Helpers.api_response(%{record: updated_entity}, context, query_options)
          else
            conn
            |> Plug.Conn.put_status(404)
            |> JetzyWeb.Helpers.api_response(%{error: "Entity Not Found"}, context, query_options)
          end
        :access_denied ->
          access_denied(m, conn, context, query_options)
      end
    end

    def delete(m, conn, params) do
      {query_options, context} = context_and_query_options(m, conn, params)
      cond do
        subject = m.request_subject(conn, params) ->
          entity = m.repo_module().get!(m.entity_module().id(subject), context, query_options)
          cond do
            entity == nil ->
              conn
              |> Plug.Conn.put_status(404)
              |> JetzyWeb.Helpers.api_response(%{error: "Entity Not Found"}, context, query_options)

            m.entity_module().has_permission!(entity, :delete, context, query_options) ->
              entity = m.repo_module().delete!(entity, context, query_options)
              conn
              |> JetzyWeb.Helpers.api_response(%{record: entity}, context, query_options)

            :access_denied ->
              access_denied(m, conn, context, query_options)
          end
        :invalid ->
          conn
          |> Plug.Conn.put_status(401)
          |> JetzyWeb.Helpers.api_response(%{error: "Invalid Identifier"}, context, query_options)
      end
    end


    #==========================================
    # Helpers
    #==========================================
    def access_denied(_m, conn, context, options \\ nil) do
      conn
      |> Plug.Conn.put_status(401)
      |> JetzyWeb.Helpers.api_response(%{error: "Permission Denied"}, context, options)
    end

    def context_and_query_options(m, conn, params, options \\ %{}) do
      context = m.context(conn, params)
      case m.query_options(conn, params, options) do
        {query_options, %CallingContext{} = updated_context} ->
          {query_options, updated_context}
        query_options ->
          {query_options, context}
      end
    end

  end


