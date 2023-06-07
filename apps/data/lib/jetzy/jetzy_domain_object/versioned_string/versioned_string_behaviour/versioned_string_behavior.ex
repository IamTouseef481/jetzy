#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedStringBehavior do
  defmodule Entity do
    defmacro __using__(_options \\ nil) do
      date_time_type = Noizu.DomainObject.DateTime.Millisecond.TypeHandler
      moderation_type = Jetzy.ModerationDetails.TypeHandler
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @universal_identifier true
        require Logger
        Noizu.DomainObject.noizu_entity do
          identifier :uuid

          @json_ignore [:verbose_mobile, :mobile]
          public_field :editor

          @json_ignore [:mobile]
          public_field :revision, 0

          public_field :title, ""
          public_field :body, ""

          @json_ignore [:mobile]
          public_field :modified_on, nil, type: unquote(date_time_type)

          @json_ignore [:mobile]
          internal_field :moderation, %Jetzy.ModerationDetails{moderation_status: :none, moderation_resolution: :none, content_flag: :none}, type: unquote(moderation_type)
        end
        
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def new(title, body) do
          %__MODULE__{
            title: title && Noizu.V3.CMS.MarkdownField.new(title),
            body: body && Noizu.V3.CMS.MarkdownField.new(body)
          }
        end

        def title(ref, default \\ "") do
          cond do
            entity = Noizu.ERP.entity!(ref) ->
              case entity.title do
                v = %Noizu.V3.CMS.MarkdownField{} -> v.markdown
                nil -> default
                v -> v
              end
            :else -> default
          end
        end

        def body(ref, default \\ "") do
          cond do
            entity = Noizu.ERP.entity!(ref) ->
              case entity.body do
                v = %Noizu.V3.CMS.MarkdownField{} -> v.markdown
                nil -> default
                v -> v
              end
            :else -> default
          end
        end

        defoverridable [
          new: 2,
          title: 1,
          title: 2,
          body: 1,
          body: 2
        ]

      end
    end
  end

  defmodule Repo do
    defmacro __using__(_options \\ nil) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        Noizu.DomainObject.noizu_repo do
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @history_repo ((Module.split(@__nzdo__entity) |> Enum.slice(0..-2)) ++ [History.Repo]) |> Module.concat()
        @history_entity ((Module.split(@__nzdo__entity) |> Enum.slice(0..-2)) ++ [History.Entity]) |> Module.concat()
        @source_field  Module.get_attribute(__MODULE__, :source_field) || :versioned_string

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def insert_history(entity, context, options) do
          struct(@history_entity, Map.delete(Map.from_struct(entity),:identifier))
          |> put_in([Access.key(@source_field)], Noizu.ERP.ref(entity))
          |> @history_repo.create(context, options)
          entity
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def insert_history!(entity, context, options) do
          struct(@history_entity, Map.delete(Map.from_struct(entity),:identifier))
          |> put_in([Access.key(@source_field)], Noizu.ERP.ref(entity))
          |> @history_repo.create!(context, options)
          entity
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def post_create_callback(entity, context, options) do
          insert_history(super(entity, context, options), context, options)
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def post_create_callback!(entity, context, options) do
          insert_history!(super(entity, context, options), context, options)
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def pre_update_callback(entity, context, options) do
          entity = super(entity, context, options)
          existing = Noizu.ERP.entity(entity.identifier)
          (!existing || existing.revision != entity.revision) && insert_history(entity, context, options) || entity
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def pre_update_callback!(entity, context, options) do
          entity = super(entity, context, options)
          existing = Noizu.ERP.entity!(entity.identifier)
          (!existing || existing.revision != entity.revision) && insert_history!(entity, context, options) || entity
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        defoverridable [
          insert_history: 3,
          insert_history!: 3,
          pre_update_callback: 3,
          pre_update_callback!: 3,
          post_create_callback: 3,
          post_create_callback!: 3,
        ]
      end
    end
  end

  defmodule TypeHandler do


    defmacro __using__(_options \\ nil) do
      quote do
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        @entity_module Module.concat((Module.split(__MODULE__) |> Enum.slice(0..-2)) ++ ["Entity"] )
        @repo_module Module.concat((Module.split(__MODULE__) |> Enum.slice(0..-2)) ++ ["Repo"] )
        require  Noizu.DomainObject
        use Amnesia
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        Noizu.DomainObject.noizu_type_handler()

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        Noizu.DomainObject.noizu_sphinx_handler()


        def __entity__(), do: @entity_module
        def __repo__(), do: @repo_module

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def sync(existing, update, context, options \\ nil) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.sync(__MODULE__, existing, update, context, options)
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def sync!(existing, update, context, options \\ nil) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.sync!(__MODULE__, existing, update, context, options)
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def strip_inspect(field, value, opts) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.strip_inspect(__MODULE__, field, value, opts)
        end


        #--------------------------------------
        # from_partial
        #--------------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def from_partial(raw ,context, options), do: from_partial!(raw, context, options)

        #--------------------------------------
        # from_partial!
        #--------------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def from_partial!(%{__struct__:  @entity_module} = v, _, _), do: v
        def from_partial!(%{} = v, context, options) do
          title = case v[:title] do
                    nil -> nil
                    v when is_bitstring(v) -> Noizu.V3.CMS.MarkdownField.new(v)
                    v = %Noizu.V3.CMS.MarkdownField{} -> v
                    v -> v
                  end
          body = case v[:body] do
                   nil -> nil
                   v when is_bitstring(v) -> Noizu.V3.CMS.MarkdownField.new(v)
                   v = %Noizu.V3.CMS.MarkdownField{} -> v
                   v -> v
                 end
          @entity_module.__struct__(
            [
              editor: v[:editor],
              revision: v[:revision] || 0,
              title: title,
              body: body,
              modified_on: v[:modified_on] || options[:modified_on] || DateTime.utc_now(),
              moderation: v[:moderation] ||  %Jetzy.ModerationDetails{moderation_status: :none, moderation_resolution: :none, content_flag: :none}
            ]
          )
        end
        def from_partial!({:ref, @entity_module, _} = ref, _, _), do: ref
        def from_partial!(_, _, _), do: nil


        #--------------------------------------
        #
        #--------------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def pre_create_callback(field, entity, context, options) do
          if x = get_in(entity, [Access.key(field)]) do
            options = options || []
            options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
            x = case from_partial(x, context, options_b) do
                  x = %{identifier: nil} -> @repo_module.create(x, context, options)
                  x -> x
                end |> Noizu.ERP.ref()
            put_in(entity, [Access.key(field)], x)
          else
            entity
          end
        end
        def pre_create_callback!(field, entity, context, options) do
          if x = get_in(entity, [Access.key(field)]) do
            options = options || []
            options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
            x = case from_partial(x, context, options_b) do
                  x = %{identifier: nil} -> @repo_module.create!(x, context, options)
                  x -> x
                end |> Noizu.ERP.ref()
            put_in(entity, [Access.key(field)], x)
          else
            entity
          end
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def post_create_callback(field, entity, context, options) do
          entity
        end

        def post_create_callback!(field, entity, context, options) do
          entity
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def pre_update_callback(field, entity, context, options) do
          if x = get_in(entity, [Access.key(field)]) do
            options = options || []
            options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
            x = case from_partial(x, context, options_b) do
                  x = %{identifier: nil} -> @repo_module.create(x, context, options)
                  x -> x
                end |> Noizu.ERP.ref()
            put_in(entity, [Access.key(field)], x)
          else
            entity
          end
        end
        def pre_update_callback!(field, entity, context, options) do
          if x = get_in(entity, [Access.key(field)]) do
            options = options || []
            options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
            x = case from_partial(x, context, options_b) do
                  x = %{identifier: nil} -> @repo_module.create!(x, context, options)
                  x -> x
                end |> Noizu.ERP.ref()
            put_in(entity, [Access.key(field)], x)
          else
            entity
          end
        end

        #-------------------------------
        #
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def dump(field, _segment, nil, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, nil}
        def dump(field, _segment, nil, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, nil}
        def dump(field, _segment, %Noizu.V3.CMS.MarkdownField{} = v, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, v.markdown}
        def dump(field, _segment, v, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, v}
        def dump(field, _segment, v, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, Noizu.ERP.ref(v)}
        def dump(field, segment, value, type, layer, context, options), do: super(field, segment, value, type, layer, context, options)

        #===============================================
        # Sphinx Handler
        #===============================================
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_field__(), do: true
        def __sphinx_expand_field__(field, indexing, settings) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.__sphinx_expand_field__(__MODULE__, field, indexing, settings)
        end
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_has_default__(_field, _indexing, _settings), do: true
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_default__(field, indexing, settings) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.__sphinx_default__(__MODULE__, field, indexing, settings)
        end
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_bits__(_field, _indexing, _settings), do: :auto
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_encoding__(field, indexing, settings) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.__sphinx_encoding__(__MODULE__, field, indexing, settings)
        end
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def __sphinx_encoded__(field, entity, indexing, settings) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.__sphinx_encoded__(__MODULE__, field, entity, indexing, settings)
        end

        #-------------------------------
        # from_json
        #-------------------------------
        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        def from_json(format, field, json, context, options) do
          Jetzy.VersionedStringBehavior.TypeHandler.Default.from_json(__MODULE__, format, field, json, context, options)
        end

        @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
        defoverridable [
          __entity__: 0,
          __repo__: 0,
          sync: 3,
          sync: 4,
          sync!: 3,
          sync!: 4,
          strip_inspect: 3,
          from_partial: 3,
          from_partial!: 3,
          pre_create_callback: 4,
          pre_create_callback!: 4,
          pre_update_callback: 4,
          pre_update_callback!: 4,
          dump: 7,
          from_json: 5,

          __sphinx_field__: 0,
          __sphinx_expand_field__: 3,
          __sphinx_has_default__: 3,
          __sphinx_default__: 3,
          __sphinx_bits__: 3,
          __sphinx_encoding__: 3,
          __sphinx_encoded__: 4,
        ]

      end
    end
  end


  defmacro __using__(_options \\ nil) do
    quote do
      use Noizu.DomainObject
      @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
      @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
    end
  end

end
