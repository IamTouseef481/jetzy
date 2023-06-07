#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedLink.TypeHandler do
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
        {field, Jetzy.VersionedLink.Entity.ref(value)}
      is_integer(opts.limit) && opts.limit < 50 ->
        name = Jetzy.Helper.truncate(Map.get(value, :name), 16)
        link = Jetzy.Helper.truncate(Map.get(value, :link), 16, middle: true)
        {field, {name, link, "@#{value.revision}"}}
      is_integer(opts.limit) && opts.limit < 100 ->
        name = Jetzy.Helper.truncate(Map.get(value, :name), 32)
        description = Jetzy.Helper.truncate(Map.get(value, :description), 32)
        link = Jetzy.Helper.truncate(Map.get(value, :link), 32, middle: true)
        {field, %{value| name: name, decription: description, link: link}}
      is_integer(opts.limit) && opts.limit < 250 ->
        name = Jetzy.Helper.truncate(Map.get(value, :name), 32)
        description = Jetzy.Helper.truncate(Map.get(value, :description), 32)
        link = Jetzy.Helper.truncate(Map.get(value, :link), 512)
        {field, %{value| name: name, decription: description, link: link}}
      is_integer(opts.limit) ->
        name = Jetzy.Helper.truncate(Map.get(value, :name), 1024)
        description = Jetzy.Helper.truncate(Map.get(value, :description), 1024)
        link = Jetzy.Helper.truncate(Map.get(value, :link), 1024)
        {field, %{value| name: name, decription: description, link: link}}
      :else ->
        {field, value}
    end
  end


  #-----------------------------------------
  #
  #-----------------------------------------
  def from_partial(raw, context, options), do: from_partial!(raw, context, options)

  #-----------------------------------------
  #
  #-----------------------------------------
  def from_partial!(%{__struct__:  @entity_module} = v, _, _), do: v
  def from_partial!(%{link: link} = v, context, options) do
    %Jetzy.VersionedLink.Entity{
      link: link,
      name: v[:name] || v[:link],
      description: v[:description] || v[:name] || nil,
      editor: v[:editor],
      modified_on: v[:modified_on] || options[:modified_on] || options[:current_time] || DateTime.utc_now()
    }
  end
  def from_partial!(link, context, options) when is_bitstring(link) do
    %Jetzy.VersionedLink.Entity{
      link: link,
      name: link,
      description: nil,
      editor: options[:editor],
      modified_on: options[:modified_on] || options[:current_time] || DateTime.utc_now()
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
                if existing = Jetzy.VersionedLink.Entity.entity!(identifier) do
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
      |> Jetzy.Helper.Json.selective_json_put(:name, j)
      |> Jetzy.Helper.Json.selective_json_put(:description, j)
      |> Jetzy.Helper.Json.selective_json_put(:link, j)
      |> Jetzy.Helper.Json.selective_json_put(:modified_on, j, &Jetzy.Helper.Json.extract_json_millisecond_date/2)
    end
  end


end
