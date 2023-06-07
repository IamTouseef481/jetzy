#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedStringBehavior.TypeHandler.Default do
  def sync(m, existing, update, _context, _options \\ nil) do
    existing = existing && Noizu.ERP.entity(existing)
    cond do
      !existing -> update
      !update -> existing
      (existing.title != update.title) || (existing.body != update.body) || (existing.editor != update.editor) ->
        %{existing| revision: existing.revision + 1, title: update.title, body: update.body, editor: update.editor, modified_on: update.modified_on}
      :else -> existing
    end
  end


  def sync!(_m, existing, update, _context, _options \\ nil) do
    existing = existing && Noizu.ERP.entity!(existing)
    cond do
      !existing -> update
      !update -> existing
      (existing.title != update.title) || (existing.body != update.body) || (existing.editor != update.editor) ->
        %{existing| revision: existing.revision + 1, title: update.title, body: update.body, editor: update.editor, modified_on: update.modified_on}
      :else -> existing
    end
  end

  def strip_inspect(m, field, value, opts) do
    entity = m.__entity__()
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
        {field, entity.ref(value)}
      is_integer(opts.limit) && opts.limit < 50 ->
        title = Jetzy.Helper.truncate(Map.get(value, :title), 15, middle: true)
        body = Jetzy.Helper.truncate(Map.get(value, :body), 15)
        revision = Map.get(value, :revision, 1)
        {field, {title, body, "@#{revision}"}}
      is_integer(opts.limit) && opts.limit < 100 ->
        title = Jetzy.Helper.truncate(Map.get(value, :title), 25, middle: true)
        body = Jetzy.Helper.truncate(Map.get(value, :body), 25)
        update = value
                 |> put_in([Access.key(:title)], title)
                 |> put_in([Access.key(:body)], body)
        {field, update}
      is_integer(opts.limit) && opts.limit < 250 ->
        title = Jetzy.Helper.truncate(Map.get(value, :title), 80, middle: true)
        body = Jetzy.Helper.truncate(Map.get(value, :body), 80)
        update = value
                 |> put_in([Access.key(:title)], title)
                 |> put_in([Access.key(:body)], body)
        {field, update}
      is_integer(opts.limit) ->
        title = Jetzy.Helper.truncate(Map.get(value, :title), 128, middle: true)
        body = Jetzy.Helper.truncate(Map.get(value, :body), 512)
        update = value
                 |> put_in([Access.key(:title)], title)
                 |> put_in([Access.key(:body)], body)
        {field, update}
      :else ->
        {field, value}
    end
  end


  def pre_create_callback(m, field, entity, context, options) do
    entity_module = m.__entity__()
    repo = m.__repo__()
    now = options[:current_time] || DateTime.utc_now()
    update_in(
      entity,
      [Access.key(field)],
      fn(v) ->
        case v do
          {:ref, ^entity_module, _} -> v
          %{__struct__: ^entity_module, identifier: nil} -> repo.create(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
          %{__struct__: ^entity_module} -> v |> Noizu.ERP.ref()
          %{} ->
            cond do
              v[:title] || v[:body] || v[:editor] ->
                struct(entity_module, [
                  title: Noizu.V3.CMS.MarkdownField.new(v[:title] || ""),
                  body: Noizu.V3.CMS.MarkdownField.new(v[:body] || ""),
                  editor: Jetzy.Helper.editor(v[:editor], entity, context, options),
                  modified_on: v[:modified_on] || now]
                ) |> repo.create(Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
              :else -> nil
            end
          _unmatched -> nil
        end
      end
    )
  end

  def pre_create_callback!(m, field, entity, context, options) do
    entity_module = m.__entity__()
    repo = m.__repo__()
    now = options[:current_time] || DateTime.utc_now()
    update_in(
      entity,
      [Access.key(field)],
      fn(v) ->
        case v do
          {:ref, ^entity_module, _} -> v
          %{__struct__: ^entity_module, identifier: nil} -> repo.create!(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
          %{__struct__: ^entity_module} -> v |> Noizu.ERP.ref()
          %{} ->
            cond do
              v[:title] || v[:body] || v[:editor] ->
                struct(entity_module, [
                  title: Noizu.V3.CMS.MarkdownField.new(v[:title] || ""),
                  body: Noizu.V3.CMS.MarkdownField.new(v[:body] || ""),
                  editor: Jetzy.Helper.editor(v[:editor], entity, context, options),
                  modified_on: v[:modified_on] || now]
                ) |> repo.create!(Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
              :else -> nil
            end
          _unmatched -> nil
        end
      end
    )
  end



  def pre_update_callback(m, field, entity, context, _options) do
    entity_module = m.__entity__()
    repo = m.__repo__()
    #now = options[:current_time] || DateTime.utc_now()
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case v do
          {:ref, ^entity_module, _} -> v
          %{__struct__: ^entity_module, identifier: identifier} when is_integer(identifier) ->
            existing = repo.get(v.identifier, context)
            cond do
              existing == nil -> repo.create(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
              existing.revision != v.revision -> repo.update(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: false) |> Noizu.ERP.ref()
              existing.title != v.title || existing.body != v.body ->
                v
                |> update_in([Access.key(:revision)], &((&1 || 0) + 1))
                |> repo.update(Noizu.ElixirCore.CallingContext.system(context), cascade_block?: false) |> Noizu.ERP.ref()
              :else -> v |> Noizu.ERP.ref()
            end
          _unmatched -> nil
        end
      end
    )
  end

  def pre_update_callback!(m, field, entity, context, _options) do
    entity_module = m.__entity__()
    repo_module = m.__repo__()
    #now = options[:current_time] || DateTime.utc_now()
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case v do
          {:ref, ^entity_module, _} -> v
          %{__struct__: ^entity_module, identifier: identifier} when is_integer(identifier) ->
            existing = repo_module.get!(v.identifier, context)
            cond do
              existing == nil -> repo_module.create!(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) |> Noizu.ERP.ref()
              existing.revision != v.revision -> repo_module.update!(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: false) |> Noizu.ERP.ref()
              existing.title != v.title || existing.body != v.body ->
                v
                |> update_in([Access.key(:revision)], &((&1 || 0) + 1))
                |> repo_module.update!(Noizu.ElixirCore.CallingContext.system(context), cascade_block?: false) |> Noizu.ERP.ref()
              :else -> v |> Noizu.ERP.ref()
            end
          _unmatched -> nil
        end
      end
    )
  end

  def post_delete_callback(m, field, entity, context, options) do
#    entity_module = m.__entity__()
#    repo_module = m.__repo__()
#    case get_in(entity, [Access.key(field)]) do
#      v = %{__struct__: ^entity_module, identifier: identifier} when is_integer(identifier) ->
#        repo_module.delete(v, context, options)
#      _unmatched -> :skip
#    end
    entity
  end



  def __sphinx_expand_field__(m, field, indexing, _settings) do
    indexing = update_in(indexing, [:from], &(&1 || field))
    [
      {:"#{field}_id", m, put_in(indexing, [:sub], :identifier)}, #rather than __MODULE__ here we could use Sphinx providers like Sphinx.NullableInteger
      {:"#{field}_title", m, put_in(indexing, [:sub], :title)},
      {:"#{field}_body", m, put_in(indexing, [:sub], :body)},
      {:"#{field}_modified_on", m, put_in(indexing, [:sub], :modified_on)},
    ]
  end

  def __sphinx_default__(_m, _field, indexing, _settings) do
    cond do
      indexing[:sub] == :identifier -> 0
      indexing[:sub] == :title -> ""
      indexing[:sub] == :body -> ""
      indexing[:sub] == :modified_on -> 0
      :else -> nil
    end
  end

  def __sphinx_encoding__(_m, _field, indexing, _settings) do
    cond do
      indexing[:sub] == :identifier -> :attr_uint
      indexing[:sub] == :title -> :field
      indexing[:sub] == :body -> :field
      indexing[:sub] == :modified_on -> :attr_timestamp
      :else -> nil
    end
  end

  def __sphinx_encoded__(_m, _field, entity, indexing, _settings) do
    value = get_in(entity, [Access.key(indexing[:from])])
            |> Noizu.ERP.entity!()
    cond do
      !value ->
        cond do
          indexing[:sub] == :identifier -> 0
          indexing[:sub] == :title -> ""
          indexing[:sub] == :body -> ""
          indexing[:sub] == :modified_on -> 0
          :else -> nil
        end
      indexing[:sub] == :identifier -> value.identifier
      indexing[:sub] == :title ->
        cond do
          is_nil(value.title)  || is_bitstring(value.title) -> value.title
          :else -> value.title.markdown
        end
      indexing[:sub] == :body ->
        cond do
          is_nil(value.body)  || is_bitstring(value.body) -> value.body
          :else -> value.body.markdown
        end
      indexing[:sub] == :modified_on -> value.modified_on && DateTime.to_unix(value.modified_on) || 0
      :else -> nil
    end
  end

  #-------------------------------
  # from_json
  #-------------------------------
  def from_json(m, _format, field, json, context, _options) do
    entity_module = m.__entity__()

    {s,j} = case json[Atom.to_string(field)] do
              vs_json = %{"identifier" => identifier} ->
                if existing = entity_module.entity!(identifier, context) do
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
      |> Jetzy.Helper.Json.selective_json_put(:body, j)
      |> Jetzy.Helper.Json.selective_json_put(:title, j)
      |> Jetzy.Helper.Json.selective_json_put(:revision, j)
      |> Jetzy.Helper.Json.selective_json_put(:editor, j, &(Noizu.ERP.ref(&1)))
      |> Jetzy.Helper.Json.selective_json_put(:modified_on, j, &Jetzy.Helper.Json.extract_json_millisecond_date/2)
    end
  end


end
