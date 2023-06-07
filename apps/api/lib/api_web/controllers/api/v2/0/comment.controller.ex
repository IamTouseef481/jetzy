#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Comment.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.Comment.Entity
  use PhoenixSwagger

  #alias Jetzy.Comment

  #========================================================
  # Constants
  #========================================================
  #@default_depth 3

  #========================================================
  # Functions
  #========================================================

  #-------------------------------------------
  #
  #-------------------------------------------
  #
  #  def index(conn, %{"subject_sref" => subject, "parent_sref" => parent} = params) do
  #    context = default_get_context(conn, params)
  #    subject_ref = Noizu.ERP.ref(subject)
  #    parent_ref = Noizu.ERP.ref(parent)
  #    if subject_ref && parent_ref do
  #      depth = params["depth"] || @default_depth
  #      options = %{depth: depth, active: true, fold: true}
  #      comments = Comment.Repo.comment_descendents(subject_ref, parent_ref, context, options)
  #      if comments do
  #        response = %{results: comments}
  #        api_response(conn, response, context)
  #      else
  #        conn
  #        |> put_status(504)
  #        |> api_response(%{msg: "Invalid Subject"}, context)
  #      end
  #    else
  #      conn
  #      |> put_status(504)
  #      |> api_response(%{msg: "Invalid Subject"}, context)
  #    end
  #  end
  #
  #  def index(conn, %{"subject_sref" => subject} = params) do
  #    context = default_get_context(conn, params)
  #    subject_ref = Noizu.ERP.ref(subject)
  #    if subject_ref do
  #      depth = params["depth"] || @default_depth
  #      options = %{depth: depth, active: true, fold: true}
  #      comments = Comment.Repo.subject_comments(subject_ref, context, options)
  #      if comments do
  #        response = %{results: comments}
  #        api_response(conn, response, context)
  #      else
  #        response = %{results: []}
  #        api_response(conn, response, context)
  #      end
  #    else
  #      conn
  #      |> put_status(504)
  #      |> api_response(%{msg: "Invalid Subject"}, context)
  #    end
  #  end
  #
  #
  #  def index(conn, params) do
  #    context = default_get_context(conn, params)
  #    results = %{} # WIP
  #    api_response(conn, results, context)
  #  end
  #
  #  #-------------------------------------------
  #  #
  #  #-------------------------------------------
  #  def show(conn, params) do
  #    context = default_get_context(conn, params)
  #    results = %{} # WIP
  #    api_response(conn, results, context)
  #  end
  #
  #  #-------------------------------------------
  #  #
  #  #-------------------------------------------
  #  def create(conn, %{"subject_sref" => subject, "parent_sref" => parent} = params) do
  #    context = default_get_context(conn, params)
  #    case Comment.Repo.template_from_json(:"1.0", subject, parent, conn.body_params, context) do
  #      post = %Comment.Entity{} ->
  #        post = %Comment.Entity{post| user: context.caller, identifier: nil}
  #        if Comment.Entity.has_permission!(post, :create, context, %{}) do
  #          post = Comment.Repo.create!(post, Noizu.ElixirCore.CallingContext.system(context))
  #          api_response(conn, %{outcome: true, post: post}, context)
  #        else
  #          api_response(conn, %{outcome: false, post: nil}, context)
  #        end
  #      _ ->
  #        api_response(conn, %{outcome: false, post: nil}, context)
  #    end
  #
  #  end
  #
  #  def create(conn, %{"subject_sref" => subject} = params) do
  #    context = default_get_context(conn, params)
  #    case Comment.Repo.template_from_json(:"1.0", subject, nil, conn.body_params, context) do
  #      post = %Comment.Entity{} ->
  #        post = %Comment.Entity{post| owner: context.caller, identifier: nil}
  #        if Comment.Entity.has_permission!(post, :create, context, %{}) do
  #          post = Comment.Repo.create!(post, Noizu.ElixirCore.CallingContext.system(context))
  #          api_response(conn, %{outcome: true, post: post}, context)
  #        else
  #          api_response(conn, %{outcome: false, post: nil}, context)
  #        end
  #      _ ->
  #        api_response(conn, %{outcome: false, post: nil}, context)
  #    end
  #  end
  #
  #  #-------------------------------------------
  #  #
  #  #-------------------------------------------
  #  def update(conn, %{"id" => _comment_sref} = params) do
  #    context = default_get_context(conn, params)
  #    _ignore = """
  #    case Noizu.ERP.entity!(comment_sref) do
  #      entity = %Comment.Entity{} ->
  #        response = if Noizu.ERP.ref(entity.owner) == context.caller && context.caller do
  #          update = Comment.Repo.from_json(conn.body_params, context, [])
  #          if update do
  #            Comment.Repo.update!(update, context)
  #          end
  #        end
  #
  #        if response do
  #          api_response(conn, response, context)
  #        else
  #          conn
  #          |> put_status(505)
  #          |> api_response(nil, context)
  #        end
  #
  #      true ->
  #        conn
  #        |> put_status(404)
  #        |> api_response(nil, context)
  #    end
  #    """
  #    results = %{} # WIP
  #    api_response(conn, results, context)
  #  end
  #
  #
  #
  #  #-------------------------------------------
  #  #
  #  #-------------------------------------------
  #  def delete(conn, params) do
  #    context = default_get_context(conn, params)
  #    results = %{} # WIP
  #    api_response(conn, results, context)
  #  end







  #---------------------------------------
  # def index/2
  #---------------------------------------
  swagger_path :index do
    PhoenixSwagger.Path.get "/v2.0/entity/{subject}/comments"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyCommentList)
  end
  def index(conn, params), do: super(conn, params)

  #---------------------------------------
  # def show/2
  #---------------------------------------
  swagger_path :show do
    PhoenixSwagger.Path.get "/v2.0/entity/{subject}/comments/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyComment)
  end
  def show(conn, params), do: super(conn, params)


  #---------------------------------------
  # def create/2
  #---------------------------------------
  swagger_path :create do
    PhoenixSwagger.Path.post "/v2.0/entity/{subject}/comments"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyComment)
  end
  def create(conn, params), do: super(conn, params)


  #---------------------------------------
  # def update/2
  #---------------------------------------
  swagger_path :update do
    PhoenixSwagger.Path.put "/v2.0/entity/{subject}/comments/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyComment)
  end
  def update(conn, params), do: super(conn, params)


  #---------------------------------------
  # def delete/2
  #---------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/v2.0/entity/{subject}/comments/{identifier}"
    summary "..."
    description "..."
    produces "application/json"
    parameters do
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:JetzyComment)
  end
  def delete(conn, params), do: super(conn, params)




  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      JetzyComment: swagger_schema do
                         title "Jetzy Comment"
                         description "Jetzy Comment Entity"
                         example (
                                    %{
                                      identifier: 1,
                                    }
                                  )
                       end,
      JetzyCommentList: swagger_schema do
                             title "Jetzy Comment List"
                             description "list of Comment entities"
                             example(
                               [%{
                                 identifier: 1,
                               }])
                           end
    }
  end



end

end