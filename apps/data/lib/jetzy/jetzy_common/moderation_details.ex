#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.ModerationDetails do
  use Amnesia
  use Noizu.SimpleObject
  @vsn 1.0
  @kind "Moderation"
  @json_format_group {:user_clients, [:compact]}
  Noizu.SimpleObject.noizu_struct() do
    @json {[:mobile, :verbose], :suppress_meta}
    public_field :moderation_status, nil, JetzySchema.Types.Moderation.Status.Enum
    public_field :moderation_resolution, nil, JetzySchema.Types.Moderation.Resolution.Enum
    public_field :content_flag, nil, JetzySchema.Types.Content.Flag.Enum
  end

  defmodule TypeHandler do
    require  Noizu.DomainObject
    Noizu.DomainObject.noizu_type_handler()
    Noizu.DomainObject.noizu_sphinx_handler()


    def strip_inspect(field, value, _opts) do
      case value do
        %{__struct__: Jetzy.ModerationDetails} ->
          flags = Enum.map(
                    [:moderation_status, :moderation_resolution, :content_flag],
                    fn (f) ->
                      v = get_in(value, [Access.key(f)])
                      v != :none && {f, v}
                    end
                  )
                  |> Enum.filter(&(&1))
          cond do
            flags == [] -> {field, :none}
            :else -> {field, flags}
          end
        nil -> {field, nil}
        _ -> {field, :auto}
      end
    end

    def pre_create_callback(field, entity, _context, _options) do
      update_in(
        entity,
        [Access.key(field)],
        fn (v) ->
          case v do
            %{__struct__: Jetzy.ModerationDetails} ->
            %Jetzy.ModerationDetails{v|
              moderation_status: v.moderation_status || :none,
              moderation_resolution: v.moderation_resolution || :none,
              content_flag: v.content_flag || :none,
             }
            _ ->
              %Jetzy.ModerationDetails{
                moderation_status: :none,
                moderation_resolution: :none,
                content_flag: :none,
              }
          end
        end
      )
    end

    def dump(:moderation, _segment, v = %{__struct__: Jetzy.ModerationDetails}, _type, %{schema: JetzySchema.Database}, _context, _options) do
      {:moderation, v}
    end
    def dump(:moderation, _segment, v = %{__struct__: Jetzy.ModerationDetails}, _type, %{schema: _repo}, _context, _options) do
      [
        {:moderation_resolution, v.moderation_resolution || :none},
        {:moderation_status, v.moderation_status  || :none},
        {:flagged, v.content_flag || :none},
      ]
    end



    #===============================================
    # Sphinx Handler
    #===============================================

    def __search_clauses__(_index, {_field, _settings}, _conn, _params, _context, _options) do
      nil
    end

    def __sphinx_field__(), do: true
    def __sphinx_expand_field__(field, indexing, _settings) do
      indexing = update_in(indexing, [:from], &(&1 || field))
      [
        {:"#{field}_status", __MODULE__, put_in(indexing, [:sub], :status)},
        #rather than __MODULE__ here we could use Sphinx providers like Sphinx.NullableInteger
        {:"#{field}_resolution", __MODULE__, put_in(indexing, [:sub], :moderation_resolution)},
        {:"#{field}_flag", __MODULE__, put_in(indexing, [:sub], :content_flag)},
      ]
    end
    def __sphinx_has_default__(_field, _indexing, _settings), do: true
    def __sphinx_default__(_field, _indexing, _settings) do
      :none
    end
    def __sphinx_encoding__(_field, indexing, _settings) do
      cond do
        indexing[:sub] == :status -> :attr_uint
        indexing[:sub] == :moderation_resolution -> :attr_uint
        indexing[:sub] == :content_flag -> :attr_uint
      end
    end
    def __sphinx_encoded__(field, entity, indexing, settings) do
      value = get_in(entity, [Access.key(indexing[:from])])
              |> Noizu.ERP.entity!()
      cond do
        !value ->
          cond do
            indexing[:sub] == :status -> JetzySchema.Types.Moderation.Status.Enum.atom_to_enum(__sphinx_default__(field, indexing, settings))
            indexing[:sub] == :moderation_resolution -> JetzySchema.Types.Moderation.Resolution.Enum.atom_to_enum(__sphinx_default__(field, indexing, settings))
            indexing[:sub] == :content_flag -> JetzySchema.Types.Content.Flag.Enum.atom_to_enum(__sphinx_default__(field, indexing, settings))
          end
        indexing[:sub] == :status -> JetzySchema.Types.Moderation.Status.Enum.atom_to_enum(value.status)
        indexing[:sub] == :moderation_resolution -> JetzySchema.Types.Moderation.Resolution.Enum.atom_to_enum(value.status)
        indexing[:sub] == :content_flag -> JetzySchema.Types.Content.Flag.Enum.atom_to_enum(value.status)
      end
    end


  end

end # end defmodule Jetzy.ModerationDetails
