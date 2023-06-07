#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedName.TypeHandler do
  use Jetzy.VersionedStringBehavior.TypeHandler

  def strip_inspect(field, value, opts) do
    cond do
      !value ->
        {field, value}
      opts.custom_options[:raw] ->
        {field, value}
      !is_map(value) ->
        {field, value}
      Map.has_key?(value, :__transient__) && value.__transient__[:inspect][:raw] ->
        {field, value}
      is_integer(opts.limit) && opts.limit < 25 ->
        {field, Jetzy.VersionedName.Entity.ref(value)}
      is_integer(opts.limit) && opts.limit < 50 ->
        first = Jetzy.Helper.truncate(Map.get(value, :first), 15)
        middle = Jetzy.Helper.truncate(Map.get(value, :middle), 1, [fill: ""])
        last = Jetzy.Helper.truncate(Map.get(value, :last), 15)
        {field, {first, middle, last, "@#{value.revision}"}}
      is_integer(opts.limit) && opts.limit < 100 ->
        first = Jetzy.Helper.truncate(Map.get(value, :first), 25)
        middle = Jetzy.Helper.truncate(Map.get(value, :middle), 25)
        last = Jetzy.Helper.truncate(Map.get(value, :last), 25)
        {field, %{value| first: first, middle: middle, last: last}}
      is_integer(opts.limit) && opts.limit < 250 ->
        first = Jetzy.Helper.truncate(Map.get(value, :first), 80)
        middle = Jetzy.Helper.truncate(Map.get(value, :middle), 80)
        last = Jetzy.Helper.truncate(Map.get(value, :last), 80)
        {field, %{value| first: first, middle: middle, last: last}}
      is_integer(opts.limit) ->
        first = Jetzy.Helper.truncate(Map.get(value, :first), 128)
        middle = Jetzy.Helper.truncate(Map.get(value, :middle), 128)
        last = Jetzy.Helper.truncate(Map.get(value, :last), 128)
        {field, %{value| first: first, middle: middle, last: last}}
      :else ->
        {field, value}
    end
  end

  def from_partial(%{__struct__:  @entity_module} = v, _, _), do: v
  def from_partial(%{first: first, last: last} = v, context, options) do
    %Jetzy.VersionedName.Entity{
      first: first || "",
      middle: v[:middle] || "",
      last: last || "",
      editor: v[:editor] || options[:editor] || context.caller,
      modified_on: v[:modified_on] || options[:modified_on] || options[:created_on] || DateTime.utc_now(),
    }
  end
  def from_partial({:ref, @entity_module, _} = ref, _, _), do: ref
  def from_partial(_, _, _), do: nil


  def from_partial!(%{__struct__:  @entity_module} = v, _, _), do: v
  def from_partial!(%{first: first, last: last} = v, context, options) do
    %Jetzy.VersionedName.Entity{
      first: first || "",
      middle: v[:middle] || "",
      last: last || "",
      editor: v[:editor]|| options[:editor] || context.caller,
      modified_on: v[:modified_on] || options[:modified_on] || options[:created_on] || DateTime.utc_now(),
    }
  end
  def from_partial!({:ref, @entity_module, _} = ref, _, _), do: ref
  def from_partial!(_, _, _), do: nil



  #-------------------------------
  # from_json
  #-------------------------------
  def from_json(_format, field, json, context, _options) do
    {s,j} = case json[Atom.to_string(field)] do
              vs_json = %{"identifier" => identifier} ->
                if existing = Jetzy.VersionedName.Entity.entity!(identifier) do
                  {existing, vs_json}
                else
                  editor = cond do
                             v = vs_json["editor"] -> Noizu.ERP.ref(v) || context.caller
                             :else -> context.caller
                           end
                  {%{editor: editor}, Map.drop(vs_json, "editor")}
                end
              vs_json = %{"body" => _body} ->
                editor = cond do
                           v = vs_json["editor"] -> Noizu.ERP.ref(v) || context.caller
                           :else -> context.caller
                         end
                {%{editor: editor}, Map.drop(vs_json, "editor")}
              _ -> {nil, nil}
            end

    if s do
      s
      |> Jetzy.Helper.Json.selective_json_put(:editor, j, &(Noizu.ERP.ref(&1)))
      |> Jetzy.Helper.Json.selective_json_put(:revision, j)
      |> Jetzy.Helper.Json.selective_json_put(:first, j)
      |> Jetzy.Helper.Json.selective_json_put(:middle, j)
      |> Jetzy.Helper.Json.selective_json_put(:last, j)
      |> Jetzy.Helper.Json.selective_json_put(:modified_on, j, &Jetzy.Helper.Json.extract_json_millisecond_date/2)
    end
  end


  def __sphinx_field__(), do: true
  def __sphinx_expand_field__(field, indexing, _settings) do
    indexing = update_in(indexing, [:from], &(&1 || field))
    [
      {:"#{field}_full", __MODULE__, put_in(indexing, [:sub], :full)},
      {:"#{field}_last", __MODULE__, put_in(indexing, [:sub], :last)},
    ]
  end
  def __sphinx_has_default__(_field, _indexing, _settings), do: false
  def __sphinx_default__(_field, _indexing, _settings), do: nil
  def __sphinx_bits__(_field, _indexing, _settings), do: :auto
  def __sphinx_encoding__(_field, _indexing, _settings), do: :field
  def __sphinx_encoded__(_field, entity, indexing, _settings) do
    value = get_in(entity, [Access.key(indexing[:from])])
            |> Noizu.ERP.entity!()
    cond do
      value == nil -> ""
      indexing[:sub] == :full -> "#{value.first} #{value.middle} #{value.last} "
      indexing[:sub] == :last -> value.last || ""
    end
  end

end
