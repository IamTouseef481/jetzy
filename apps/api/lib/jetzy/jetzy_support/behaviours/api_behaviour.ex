#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule JetzyElixir.ApiBehaviour do
  alias Noizu.ElixirCore.CallingContext
  @type opts :: Map.t
  @type params :: Map.t
  @type api_response :: any
  @type action :: :index | :show | :create | :edit | :delete

  #-------------------------
  # Behaviour
  #-------------------------

  # Get details from conn methods.
  @callback request_subject(Plug.Conn.t, params, opts) :: {:ref, Module, any} | nil
  @callback context(Plug.Conn.t, params, opts) :: CallingContext.t
  @callback query_options(Plug.Conn.t, map(), opts) :: opts | {opts, CallingContext.t}
  @callback query_pagination(Plug.Conn.t, map(), opts) :: opts

  # API CRUD Actions
  @callback index(Plug.Conn.t, params) :: api_response
  @callback show(Plug.Conn.t, params) :: api_response
  @callback create(Plug.Conn.t, params) :: api_response
  @callback edit(Plug.Conn.t, params) :: api_response
  @callback delete(Plug.Conn.t, params) :: api_response

  defmacro __using__(options) do
    entity_module = options[:entity_module]
    implementation = options[:implementation] || JetzyElixir.ApiBehaviour.Default
    pagination = options[:default_pagination]
    if entity_module == nil do
      raise "entity_module is a required ApiBehaviour option"
    end

    quote do
      use Amnesia
      @entity_module unquote(entity_module)
      @repo_module @entity_module.__repo__()
      @implementation unquote(implementation)
      @__nzdo__default_pagination unquote(pagination) || (Module.has_attribute?(__MODULE__, :default_pagination) && Module.get_attribute(__MODULE__, :default_pagination)) || 50

      def entity_module(), do: @entity_module
      def repo_module(), do: @repo_module
      def implementation(), do: @implementation

      #==========================================
      # Get details from conn methods.
      #==========================================
      @doc """
          Get entity from query param.
      """
      def request_subject(conn, params, options \\ nil), do: @implementation.request_subject(__MODULE__, conn, params, options)

      @doc """
          Get request context object.
      """
      def context(conn, params, options \\ %{}), do: @implementation.context(__MODULE__, conn, params, options)

      @doc """
          Get request query options
      """
      def query_options(conn, params, options \\ %{}) do
        @implementation.query_options(__MODULE__, conn, params, options)
      end

      @doc """
          Get request pagination options
      """
      def query_pagination(conn, params, options \\ %{}) do
        @implementation.query_pagination(__MODULE__, conn, params, options)
      end

      #==========================================
      # API CRUD Actions
      #==========================================
      def index(conn, params), do: @implementation.index(__MODULE__, conn, params)
      def show(conn, params), do: @implementation.show(__MODULE__, conn, params)
      def create(conn, params), do: @implementation.create(__MODULE__, conn, params)
      def update(conn, params), do: @implementation.edit(__MODULE__, conn, params)
      def delete(conn, params), do: @implementation.delete(__MODULE__, conn, params)

      def default_pagination_size(), do: @__nzdo__default_pagination

      defoverridable [
        entity_module: 0,
        repo_module: 0,
        implementation: 0,
        request_subject: 2,
        request_subject: 3,
        context: 2,
        context: 3,
        query_options: 2,
        query_options: 3,
        query_pagination: 2,
        query_pagination: 3,
        index: 2,
        show: 2,
        create: 2,
        update: 2,
        delete: 2,
        default_pagination_size: 0,
      ]
    end
  end
end
