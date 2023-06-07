#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule JetzyWeb.Helpers do
  alias Noizu.ElixirCore.CallingContext
  use Amnesia
  require Logger
  use Noizu.AdvancedScaffolding.Helpers.CustomHelper

  defmodule Records do
    defmodule ApiResponse do
      require Record
      Record.defrecord(:api_response, status: 200, code: 200, message: nil, response: nil)
      @type api_response :: record(:api_response, status: integer | :ok, code: integer | nil, message: nil | String.t, response: any)
    end
    defmodule StatusField do
      require Record
      Record.defrecord(:status_field, field: nil, white_list: :boolean)
      @type status_field :: record(:status_field, field: atom, white_list: atom)
    end
  end
  
  
  def sref_module(m), do: m.__sref__()

  def sref_to_module(sref) do
    Jetzy.DomainObject.Schema.sref_map()[sref]
  end

  #-------------------------
  # extract_json_millisecond_date
  #-------------------------
  def extract_json_millisecond_date(d, p) do
    cond do
      is_integer(d) -> DateTime.from_unix(d, :millisecond)
      is_bitstring(d) ->
        case DateTime.from_iso8601(d) do
          {:ok, dt} -> dt
          _ -> p
        end
      :else -> p
    end
  end


  #-------------------------
  # extract_json_second_date
  #-------------------------
  def extract_json_second_date(d, p) do
    cond do
      is_integer(d) -> DateTime.from_unix(d, :second)
      is_bitstring(d) ->
        case DateTime.from_iso8601(d) do
          {:ok, dt} -> dt
          _ -> p
        end
      :else -> p
    end
  end


  #-------------------------
  # selective_json_put
  #-------------------------
  def selective_json_put(entity, key, json, transformation \\ nil) do
    cond do
      Map.has_key?(json, Atom.to_string(key)) ->
        previous_value = get_in(entity, [Access.key(key)])
        v = cond do
              is_function(transformation, 1) -> transformation.(json[Atom.to_string(key)])
              is_function(transformation, 2) -> transformation.(json[Atom.to_string(key)], previous_value)
              is_function(transformation, 3) -> transformation.(key, json[Atom.to_string(key)], previous_value)
              :else -> json[Atom.to_string(key)]
            end
        put_in(entity, [Access.key(key)], v)
      :else -> entity
    end
  end

  #-------------------------
  # api_system_key
  #-------------------------
  def api_system_key(conn, _params, _options) do
    case Plug.Conn.get_req_header(conn, "x-jetzy-api-key") do
      [] -> false
      [h | _t] -> (valid_api_key(h))
    end
  end

  #-------------------------
  # valid_api_key
  #-------------------------
  def valid_api_key(k) do
    k == Application.get_env(:jetzy, :master_api_key)
  end

  #-------------------------
  # format_to_tuple
  #-------------------------
  def format_to_tuple(v) do
    case v do
      [m, f] ->
        m = Jetzy.DomainObject.Schema.__noizu_info__(:srefmap)[String.trim(m)]
        f = JetzyWeb.Helpers.format_to_atom(f, nil)
        m && f && {m, f}
      [m, _s, _f] ->
        m = Jetzy.DomainObject.Schema.__noizu_info__(:srefmap)[String.trim(m)]
        case m do
          Jetzy.Image.Entity ->
            cond do
#              sub_type = Jetzy.Image.Type.Enum.Ecto.EnumType.json_to_atom()[s] ->
#                f = JetzyWeb.Helpers.format_to_atom(f, nil)
#                m && f && {{m, sub_type}, f}
              :bad_request -> nil
            end
          _ ->
            # unsupported sub selector.
            nil
        end
      _ -> nil
    end
  end

  #-------------------------
  # unauthenticated_ref
  #-------------------------
  def unauthenticated_ref(conn) do
    Jetzy.System.UnauthenticatedUser.ref(Noizu.AdvancedScaffolding.Helpers.get_ip(conn))
  end # end unauthenticated_ref/1


  #-------------------------
  #
  #-------------------------
  def json_time(json, default \\ nil) do
    cond do
      is_integer(json) -> DateTime.from_unix(json)
      is_bitstring(json) ->
        case DateTime.from_iso8601(json) do
          {:ok, t} -> t
          _ -> default
        end
      :else -> default
    end
  end

  def boolean_query_param(param, params, default \\ false) do
    cond do
      params[param] == "true" -> true
      params[param] == "t" -> true
      params[param] == "1" -> true
      params[param] == "false" -> false
      params[param] == "f" -> false
      params[param] == "0" -> false
      Map.has_key?(params, param) && params[param] == nil -> true
      :else -> default
    end
  end

  def numeric_query_param(param, params, default \\ nil) do
    case params[param] do
      v when is_bitstring(v) ->
        case Integer.parse(v) do
          {i, ""} -> i
          _ -> default
        end
      _ -> default
    end
  end

  #-------------------------
  #
  #-------------------------
  def default_get_context(conn, params, opts \\ %{})
  def default_get_context(conn, params, opts) do
    # Tanbits pipes incoming through a camel case encoder, so we for backwards compatibility we need to adjust our param set.
    # This likely also impacts conn.request_boday and request-id, request-reason
    params = Map.has_key?(params, "expand_all_refs") && put_in(params, ["expand-all-refs"], params["expand_all_refs"]) || params
    params = Map.has_key?(params, "expand_refs") && put_in(params, ["expand-refs"], params["expand_refs"]) || params
    params = Map.has_key?(params, "default_json_format") && put_in(params, ["default-json-format"], params["default_json_format"]) || params
    params = Map.has_key?(params, "json_formats") && put_in(params, ["json-formats"], params["json_formats"]) || params
    
    {token, reason, context_options} = Noizu.AdvancedScaffolding.Helpers.__default_get_context__token_reason_options__(conn, params, __MODULE__, opts)
    system = api_system_key(conn, params, opts)
    {caller, auth} = case Api.Guardian.Plug.current_resource(conn) do
                       auth = %{"identifier" => user_identifier} ->
                         permissions = JetzyModule.AccessControlList.get_permissions(user_identifier)
                                       |> update_in([:system], &(&1 || system))
                         {Noizu.ERP.ref(auth), %{firebase_identifier: nil, permissions: permissions}}
                       auth = %{identifier: user_identifier} ->
                         permissions = JetzyModule.AccessControlList.get_permissions(user_identifier)
                                       |> update_in([:system], &(&1 || system))
                         {Noizu.ERP.ref(auth), %{firebase_identifier: nil, permissions: permissions}}
                         auth = %{id: user_identifier} ->
                           permissions = JetzyModule.AccessControlList.get_permissions(user_identifier)
                                         |> update_in([:system], &(&1 || system))
                           {Jetzy.User.Entity.ref(user_identifier), %{firebase_identifier: nil, permissions: permissions}}
                       _ ->
                         caller = if system, do: {:ref, Jetzy.SystemContext, :internal}, else: unauthenticated_ref(conn)
                         {
                           caller,
                           %{
                             firebase_identifier: nil,
                             permissions: %{
                               system: system
                             }
                           }
                         }
                     end
    %CallingContext{
      caller: caller,
      auth: auth,
      token: token,
      reason: reason,
      time: :os.system_time(:seconds),
      options: context_options
    }
  end # end get_context/3


  #-------------------------------
  #   Handle Default Pagination Response
  #--------------------------------
  def pagination_resp(data, %{page_number: page_number, total_entries: total_entries, total_pages: total_pages}) do
    page_data =
    %{
      total_rows: total_entries,
      page: page_number,
      total_pages: total_pages
    }

    %{data: data, pagination: page_data}
  end

  def pagination_resp(data, _), do: data
end
