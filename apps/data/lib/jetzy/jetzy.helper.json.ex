
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

defmodule Jetzy.Helper.Json do
  use Amnesia
  require Logger

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
  # expand_ref?
  #-------------------------
  def expand_ref?(path, depth, options \\ nil), do: Noizu.AdvancedScaffolding.Helpers.expand_ref?(path, depth, options)

  #-------------------------
  # selective_json_put
  #-------------------------
  def force_put(entity, path, value), do: Noizu.AdvancedScaffolding.Helpers.force_put(entity, path, value)

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
  # json_time
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

end
