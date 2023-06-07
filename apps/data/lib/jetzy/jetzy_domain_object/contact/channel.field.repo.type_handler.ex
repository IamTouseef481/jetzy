#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Contact.Channel.Field.Repo.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()
  #----------------------------------
  #
  #----------------------------------
  alias Jetzy.Contact.Channel.Field.Repo
  alias Jetzy.Contact.Channel.Field.Entity
  alias Jetzy.Contact.Channel.Field.TypeHandler, as: EntityTypeHandler


  #----------------------
  # from_partial
  #----------------------
  def from_partial(%{__struct__: Repo} = v, context, options) do
    entities = Enum.map(v.entities, &(EntityTypeHandler.from_partial(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{v| entities: entities, length: length(entities)}
  end
  def from_partial(%{fields: fields} = v, context, options) do
    entities = Enum.map(fields, &(EntityTypeHandler.from_partial(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{entities: entities, length: length(entities)}
  end
  def from_partial(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(EntityTypeHandler.from_partial(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{entities: entities, length: length(entities)}
  end
  def from_partial(_, _context, _options) do
    %Repo{entities: [], length: 0}
  end

  #----------------------
  # from_partial
  #----------------------
  def from_partial!(%{__struct__: Repo} = v, context, options) do
    entities = Enum.map(v.entities, &(EntityTypeHandler.from_partial!(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{v| entities: entities, length: length(entities)}
  end
  def from_partial!(%{fields: fields} = v, context, options) do
    entities = Enum.map(fields, &(EntityTypeHandler.from_partial(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{entities: entities, length: length(entities)}
  end
  def from_partial!(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(EntityTypeHandler.from_partial!(&1, context, options))) |> Enum.filter(&(&1))
    %Repo{entities: entities, length: length(entities)}
  end
  def from_partial!(_, _context, _options) do
    %Repo{entities: [], length: 0}
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      set = from_partial(x, context, options_b)
      entities = Enum.map(
        set.entities || [],
        fn
          (%{identifier: nil} = s) -> Repo.create(s, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
          (v) -> v
        end
      )
      post_set = Enum.filter(entities, &(is_struct(&1) && &1.__transient__[:persist?]))
      insert_set = Enum.map(entities, &(Noizu.ERP.ref(&1))) |> Enum.filter(&(&1))
      entity
      |> put_in([Access.key(field)], %Repo{set | entities: insert_set, length: length(insert_set)})
      |> put_in([Access.key(:__transient__), field], %Repo{set | entities: post_set, length: length(post_set)})
    else
      entity
    end
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback!(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      set = from_partial!(x, context, options_b)
      entities = Enum.map(
        set.entities || [],
        fn
          (%{identifier: nil} = s) -> Repo.create!(s, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
          (v) -> v
        end
      )
      post_set = Enum.filter(entities, &(is_struct(&1) && &1.__transient__[:persist?]))
      insert_set = Enum.map(entities, &(Noizu.ERP.ref(&1))) |> Enum.filter(&(&1))
      entity
      |> put_in([Access.key(field)], %Repo{set | entities: insert_set, length: length(insert_set)})
      |> put_in([Access.key(:__transient__), field], %Repo{set | entities: post_set, length: length(post_set)})
    else
      entity
    end
  end

  def post_create_callback(field, entity, context, options) do
    {set, entity} = pop_in(entity, [Access.key(:__transient__), field])
    case set do
      %Repo{entities: entities} when is_list(entities) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        entities
        |> Enum.filter(&(is_struct(&1) && &1.__transient__[:persist?]))
        |> Enum.map(&(Repo.create(&1, context, options)))
      _ -> :skip
    end
    entity
  end

  def post_create_callback!(field, entity, context, options) do
    {set, entity} = pop_in(entity, [Access.key(:__transient__), field])
    case set do
      %Repo{entities: entities} when is_list(entities) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        entities
        |> Enum.filter(&(is_struct(&1) && &1.__transient__[:persist?]))
        |> Enum.map(&(Repo.create!(&1, context, options)))
      _ -> :skip
    end
    entity
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback(field, entity, context, options) do
    pre_create_callback(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback!(field, entity, context, options) do
    pre_create_callback!(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def post_update_callback(field, entity, context, options) do
    post_create_callback(field, entity, context, options)
  end

  #-------------------------------
  #
  #-------------------------------
  def post_update_callback!(field, entity, context, options) do
    post_create_callback!(field, entity, context, options)
  end


  #==================================================
  # Sphinx Handler
  #==================================================
  def __sphinx_encoding__(_field, _indexing, _settings), do: :attr_multi_64
  def __sphinx_has_default__(_field, _indexing, _settings), do: true
  def __sphinx_default__(_field, _indexing, _settings), do: []
  def __sphinx_encoded__(field, entity, _indexing, _settings) do
    value = get_in(entity, [Access.key(field)])
    cond do
      !value -> []
      !value.entities -> []
      :else -> Enum.map(value.entities, &(Noizu.ERP.id(&1)))
    end
  end
end

