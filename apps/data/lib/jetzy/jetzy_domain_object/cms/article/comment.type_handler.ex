#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2021 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Comment.TypeHandler do
  require  Noizu.DomainObject
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()



  #---------------------------------
  # sync
  #---------------------------------
  def sync(existing, update, context, options \\ nil)
  def sync(nil, update, _context, _options), do: update
  def sync(existing, update, context, options) do
    existing = Noizu.ERP.entity(existing)
    directive = cond do
                  !existing -> :update
                  update[:body] && existing.body.markdown != update[:body] -> :merge
                  update[:editor] && existing.editor != update[:editor] -> :merge
                  :else -> :existing
                end
    case directive do
      :update -> update
      :existing -> existing
      :merge ->
        %Jetzy.CMS.Article.Comment.Entity{
          existing |
          body: Noizu.V3.CMS.MarkdownField.new(update[:body] || existing.body.markdown),
          editor: update[:editor] || existing.editor,
          media: Jetzy.Entity.Image.Repo.TypeHandler.sync(existing.media, update[:media], context, options),
          time_stamp: update[:time_stamp] || existing.time_stamp || Noizu.DomainObject.TimeStamp.Second.now(options)
        }
        |> Noizu.V3.CMS.Article.CMS.new_revision(context)
    end
  end

  #---------------------------------
  # sync!
  #---------------------------------
  def sync!(existing, update, context, options \\ nil)
  def sync!(nil, update, _context, _options), do: update
  def sync!(existing, update, context, options) do
    existing = Noizu.ERP.entity!(existing)
    directive = cond do
                  !existing -> :update
                  update[:body] && existing.body.markdown != update[:body] -> :merge
                  update[:editor] && existing.editor != update[:editor] -> :merge
                  :else -> :existing
                end
    case directive do
      :update -> update
      :existing -> existing
      :merge ->
        %Jetzy.CMS.Article.Post.Entity{
          existing |
          body: Noizu.V3.CMS.MarkdownField.new(update[:body] || existing.body.markdown),
          editor: update[:editor] || existing.editor,
          media: Jetzy.Entity.Image.Repo.TypeHandler.sync!(existing.media, update[:media], context, options),
          time_stamp: update[:time_stamp] || existing.time_stamp || Noizu.DomainObject.TimeStamp.Second.now(options)
        }
        |> Noizu.V3.CMS.Article.CMS.new_revision!(context)
    end
  end


  #---------------------------------
  # pre_create_callback
  #---------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case v do
          v = %{__struct__: Jetzy.CMS.Article.Comment.Entity} ->
            cond do
              v.identifier -> v
              :else -> Jetzy.CMS.Article.Repo.create(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true)
            end
          v = %{} ->
            cond do
              v[:title] || v[:body] || v[:media] ->
                struct(
                  Jetzy.CMS.Article.Comment.Entity,
                  [
                    title: v[:title],
                    body: v[:body],
                    editor: Jetzy.Helper.editor(v[:editor], entity, context, options),
                    time_stamp: v[:time_stamp] || Noizu.DomainObject.TimeStamp.Second.now(options),
                    media: v[:media]
                  ]
                )
                |> Jetzy.CMS.Article.Repo.create(Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true)
              :else ->
                nil
            end
          _unmatched ->
            nil
        end
      end
    )
  end

  #---------------------------------
  # pre_create_callback!
  #---------------------------------
  def pre_create_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      pre_create_callback(field, entity, context, options)
    end
  end

  #---------------------------------
  # pre_update_callback
  #---------------------------------
  def pre_update_callback(field, entity, context, _options) do
    #now = options[:current_time] || DateTime.utc_now()
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case v do
          %{__struct__: Jetzy.CMS.Article.Comment.Entity, identifier: identifier} when identifier != nil ->
            existing = Jetzy.CMS.Article.Repo.get!(v.identifier, context)
            step = cond do
                     existing == nil -> :create
                     existing.title.markdown != v.title.markdown -> :update
                     existing.body.markdown != v.body.markdown -> :update
                     existing.editor != v.editor -> :update
                     Jetzy.Entity.Image.TypeHandler.compare(existing.media, v.media) == :ne -> :revision
                     :else -> :nop
                   end
            cond do
              step == :create -> Jetzy.CMS.Article.Repo.create(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true)
              step == :nop -> v
              v.__transient__[:version] -> Noizu.V3.CMS.Article.CMS.new_version(v, context)
              v.__transient__[:new_revision] -> Noizu.V3.CMS.Article.CMS.new_revision(v, context)
              :else -> Jetzy.CMS.Article.Repo.update(v, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true)
            end
          _unmatched -> nil
        end
      end
    )
  end

  #---------------------------------
  # pre_update_callback!
  #---------------------------------
  def pre_update_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      pre_update_callback(field, entity, context, options)
    end
  end

  #---------------------------------
  # post_delete_callback
  #---------------------------------
  def post_delete_callback(_field, entity, _context, _options) do
    # todo need cms delete operation.
    entity
  end

  #---------------------------------
  # post_delete_callback!
  #---------------------------------
  def post_delete_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      post_delete_callback(field, entity, context, options)
    end
  end

  #---------------------------------
  # dump
  #---------------------------------


  #--------------------------------------
  # cast
  #--------------------------------------
  def dump(field, _segment, nil, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, nil}
  def dump(field, _segment, nil, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, nil}
  def dump(field, _segment, v, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, Noizu.ERP.ref(v)}
  def dump(field, _segment, v, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, Noizu.ERP.ref(v)}
  def dump(field, segment, value, type, layer, context, options), do: super(field, segment, value, type, layer, context, options)


  #-------------------------------
  # from_json
  #-------------------------------
  def from_json(format, field, json, context, options) do
    {s, j} = case json[Atom.to_string(field)] do
               vs_json = %{"identifier" => identifier} ->
                 if existing = Jetzy.CMS.Article.Comment.Entity.entity!(identifier, context) do
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
      |> Jetzy.Helper.Json.selective_json_put(:editor, j, &(Noizu.ERP.ref(&1)))
        # |> Jetzy.Helper.Json.selective_json_put(:attributes, j)
      |> Jetzy.Helper.Json.selective_json_put(
           :media,
           fn (_v, p) ->
             mj = Jetzy.Entity.Image.Repo.TypeHandler.from_json(format, :media, j, context, options)
             Jetzy.Entity.Image.Repo.TypeHandler.sync!(p, mj, context, options)
           end
         )
      |> Jetzy.Helper.Json.selective_json_put(
           :time_stamp,
           fn (_v, p) ->
             tj = Noizu.DomainObject.TimeStamp.Second.TypeHandler.from_json(format, :time_stamp, j, context, options)
             Noizu.DomainObject.TimeStamp.Second.TypeHandler.sync!(p, tj, context, options)
           end
         )
    end
  end

  #===============================================
  # Sphinx Handler
  #===============================================
  def __sphinx_field__(), do: true
  def __sphinx_expand_field__(field, indexing, _settings) do
    indexing = update_in(indexing, [:from], &(&1 || field))
    [
      {:"#{field}_body", __MODULE__, put_in(indexing, [:sub], :body)},
      {:"#{field}_created_on", __MODULE__, put_in(indexing, [:sub], :created_on)},
      {:"#{field}_modified_on", __MODULE__, put_in(indexing, [:sub], :modified_on)},
      {:"#{field}_deleted", __MODULE__, put_in(indexing, [:sub], :deleted)},
    ]
  end
  def __sphinx_has_default__(_field, _indexing, _settings), do: true
  def __sphinx_default__(_field, indexing, _settings) do
    cond do
      indexing[:sub] == :body -> ""
      indexing[:sub] == :modified_on -> 0
      indexing[:sub] == :created_on -> 0
      indexing[:sub] == :deleted -> 0
      :else -> nil
    end
  end
  def __sphinx_bits__(_field, _indexing, _settings), do: :auto
  def __sphinx_encoding__(_field, indexing, _settings) do
    cond do
      indexing[:sub] == :body -> :field
      indexing[:sub] == :created_on -> :attr_timestamp
      indexing[:sub] == :modified_on -> :attr_timestamp
      indexing[:sub] == :deleted -> :attr_uint
      :else -> nil
    end
  end
  def __sphinx_encoded__(_field, entity, indexing, _settings) do
    value = get_in(entity, [Access.key(indexing[:from])])
            |> Noizu.ERP.entity!()
    cond do
      !value ->
        cond do
          indexing[:sub] == :body -> ""
          indexing[:sub] == :created_on -> nil
          indexing[:sub] == :modified_on -> nil
          indexing[:sub] == :deleted -> nil
          :else -> nil
        end
      indexing[:sub] == :body -> value.body
      indexing[:sub] == :created_on -> value.time_stamp && value.time_stamp.created_on && DateTime.to_unix(value.time_stamp.created_on)
      indexing[:sub] == :modified_on -> value.time_stamp && value.time_stamp.modified_on && DateTime.to_unix(value.time_stamp.modified_on)
      indexing[:sub] == :deleted -> value.time_stamp && value.time_stamp.deleted_on && 1 || 0
      :else -> nil
    end
  end
end
