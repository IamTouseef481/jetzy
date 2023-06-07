#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 SZ Global, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Parsers.Json do
  @behaviour Plug.Parsers
  import Plug.Conn
  require Logger

  #-------------------------------------
  #
  #-------------------------------------
  def init(settings) do
    settings
  end

  #-------------------------------------
  #
  #-------------------------------------
  def method(%Plug.Conn{method: method}), do: method

  #-------------------------------------
  #
  #-------------------------------------
  def info(:error, error), do: {inspect(error.__struct__), Exception.message(error)}
  def info(:throw, thrown), do: {"caught throw", inspect(thrown)}
  def info(:simple, simple), do: {"unexpected state", inspect(simple)}
  def info(:exit, reason), do: {"caught exit", Exception.format_exit(reason)}

  #-------------------------------------
  #
  #-------------------------------------
  def maybe_fetch_session(conn) do
    if conn.private[:plug_session_fetch] do
      conn |> fetch_session(conn) |> get_session()
    end
  end

  #-------------------------------------
  #
  #-------------------------------------
  def maybe_fetch_query_params(conn) do
    fetch_query_params(conn).params
  rescue
    Plug.Conn.InvalidQueryError ->
      case conn.params do
        %Plug.Conn.Unfetched{} -> %{}
        params -> params
      end
  end

  #-------------------------------------
  #
  #-------------------------------------
  def url(%Plug.Conn{scheme: scheme, host: host, port: port} = conn) do
    "#{scheme}://#{host}:#{port}#{conn.request_path}"
  end
  
  #---------------------------------
  #
  #---------------------------------
  def log_error({:error, details}, stack, conn, _headers) do
    params = maybe_fetch_query_params(conn)
    {kind, reason} = case details do
                       {kind, reason} when kind in [:error, :throw, :exit] -> {kind, reason}
                       other -> {:simple, other}
                     end
    method = method(conn)
    {title, message} = info(kind, reason)
    exception_message = cond do
                          kind == :simple -> message
                          :else -> Exception.format(kind, reason, stack)
                        end
    url = url(conn)
    headers = Enum.map(conn.req_headers, fn({key,value}) -> "    * #{key}: #{value}" end) |> Enum.join("\n")
    raw = Map.get(conn.private, :raw_body)
    truncated_raw = cond do
                      !raw -> "<NULL>"
                      !is_bitstring(raw) ->  "#{inspect raw}"
                      String.length(raw) > 256 -> String.slice(raw, 0..64) <> "\n.\n.\n.\n" <> String.slice(raw, -64..-1)
                      :else -> raw
                    end |> String.replace("\n", "\n    ")
    formatted = exception_message |> String.replace("\n", "\n    ")

    Logger.warn(fn() ->
      """
      -------------- [#{__MODULE__} request error] ------------------------------------
      # #{title} at #{method} #{conn.request_path}
      
      Exception:
      #{formatted}
  
      ## Connection details
  
      ### Params
      #{(inspect params, pretty: true) |> String.replace("\n", "\n    ")}
  
      ### Request info
      * URI: #{url}
      * Query string: #{conn.query_string}
  
      ### Headers
      #{headers}
  
      ### Body
      <[#{truncated_raw}]>
      _________________________________________________________________________________
      """
    end)
  end
  
  #---------------------------------
  #
  #---------------------------------
  def parse(conn, "application", subtype, headers, opts) do
    cond do
      subtype == "json" || String.ends_with?(subtype, "+json") ->
        decoder = Keyword.get(opts, :json_decoder) || raise ArgumentError, "JSON parser expects a :json_decoder option"
        copy_body = Keyword.get(opts, :copy_body)
        copy_body = cond do
                      is_function(copy_body) -> copy_body.(conn)
                      copy_body -> true
                      :else -> false
                    end
        decode(read_body(conn, opts), decoder, copy_body, conn, headers)
      :else -> {:next, conn}
    end
  end
  
  def parse(conn, _type, _subtype, _headers, _opts), do: {:next, conn}
  defp decode({:more, _, conn}, _decoder, _copy_body, _conn, _headers), do: {:error, :too_large, conn}
  defp decode(error = {:error, :timeout}, _decoder, _copy_body, conn, headers) do
    log_error(error, nil, conn, headers)
    #{:ok, %{"_json_error" => :timeout}, conn}
    raise Plug.TimeoutError
  end
  defp decode(error = {:error, e}, _decoder, _copy_body, conn, headers) do
    log_error(error, nil, conn, headers)
    #{:ok, %{"_json_error" => e}, conn}
    raise Plug.BadRequestError
  end
  defp decode({:ok, body = "", conn}, _decoder, copy_body, _conn, _headers) do
    #-------- MODIFIED ------------
    # attach initial body for HMAC Validation
    conn = copy_body && Plug.Conn.put_private(conn, :raw_body, body) || conn
    #------------------------------
    {:ok, %{}, conn}
  end
  defp decode({:ok, body, conn}, decoder, copy_body, _conn, headers) do
    # attach initial body for HMAC Validation
    conn = copy_body && Plug.Conn.put_private(conn, :raw_body, body) || conn
    try do
      case decoder.decode!(body) do
        terms when is_map(terms) -> {:ok, terms, conn}
        terms -> {:ok, %{"_json" => terms}, conn}
      end
    rescue e ->
      log_error({:error, {:error, Plug.Parsers.ParseError.__struct__(exception: e)}}, __STACKTRACE__, conn, headers)
      #{:ok, %{"_json" => nil, "_json_error" => {:rescue, e}}, conn}
      raise Plug.Parsers.ParseError, exception: e
    catch
      :exit, e ->
        log_error({:error, {:exit, e}}, __STACKTRACE__, conn, headers)
        #{:ok, %{"_json" => nil, "_json_error" => {:rescue, e}}, conn}
        raise Plug.Parsers.ParseError, exception: e
      e ->
        log_error({:error, {:throw, e}}, __STACKTRACE__, conn, headers)
        #{:ok, %{"_json" => nil, "_json_error" => {:rescue, e}}, conn}
        raise Plug.Parsers.ParseError, exception: e
    end
  end
end
