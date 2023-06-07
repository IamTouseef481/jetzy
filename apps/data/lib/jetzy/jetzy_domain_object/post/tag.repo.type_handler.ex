#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Tag.Repo.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()


  #----------------------
  # from_partial
  #----------------------
  def from_partial(%{__struct__: Jetzy.Post.Tag.Repo} = v, _context, _options), do: v
  def from_partial(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(Jetzy.Post.Tag.TypeHandler.from_partial(&1, context, options)))
               |> Enum.filter(&(&1))
    %Jetzy.Post.Tag.Repo{entities: entities, length: length(entities)}
  end
  def from_partial(_, _context, _options) do
    %Jetzy.Post.Tag.Repo{entities: [], length: 0}
  end

  #----------------------
  # from_partial!
  #----------------------
  def from_partial!(%{__struct__: Jetzy.Post.Tag.Repo} = v, _context, _options), do: v
  def from_partial!(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(Jetzy.Post.Tag.TypeHandler.from_partial!(&1, context, options)))
               |> Enum.filter(&(&1))
    %Jetzy.Post.Tag.Repo{entities: entities, length: length(entities)}
  end
  def from_partial!(_, _context, _options) do
    %Jetzy.Post.Tag.Repo{entities: [], length: 0}
  end



  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback(field, entity, context, options) do
    options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
                    |> update_in(
                         [:owner],
                         fn (p) ->
                           cond do
                             p -> p
                             v = Map.get(entity, :owner) -> v
                             v = Map.get(entity, :user) -> v
                             :else -> nil
                           end
                         end
                       )
        interests = from_partial(x, context, options_b)
        entities = Enum.map(
          interests && interests.entities || [],
          fn
            (%{identifier: nil} = s) -> Jetzy.Post.Tag.Repo.create(s, context, options)
            (v) -> v
          end
        )
        %Jetzy.Post.Tag.Repo{interests | entities: entities}
      end
    )
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback!(field, entity, context, options) do
    options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
                    |> update_in(
                         [:owner],
                         fn (p) ->
                           cond do
                             p -> p
                             v = Map.get(entity, :owner) -> v
                             v = Map.get(entity, :user) -> v
                             :else -> nil
                           end
                         end
                       )
        interests = from_partial!(x, context, options_b)
        entities = Enum.map(
          interests && interests.entities || [],
          fn
            (%{identifier: nil} = s) -> Jetzy.Post.Tag.Repo.create!(s, context, options)
            (v) -> v
          end
        )
        %Jetzy.Post.Tag.Repo{interests | entities: entities}
      end
    )
  end

  def post_create_callback(field, entity, context, options) do
    options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], true)))
              |> put_in([:cascade?], false)
              |> put_in([:override_identifier], true)

    tags = get_in(entity, [Access.key(field)])
    case tags do
      %Jetzy.Post.Tag.Repo{entities: entities} ->
        entities
        |> Enum.filter(&(is_struct(&1) && &1.__transient__[:persist?]))
        |> Enum.map(&( Jetzy.Post.Tag.Repo.create(&1, context, options)))
      _ -> nil
    end
    entity
  end

  def post_create_callback!(field, entity, context, options) do
    options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], true)))
              |> put_in([:cascade?], false)
              |> put_in([:override_identifier], true)

    tags = get_in(entity, [Access.key(field)])
    case tags do
      %Jetzy.Post.Tag.Repo{entities: entities} ->
        entities
        |> Enum.filter(&(is_struct(&1) && &1.__transient__[:persist?]))
        |> Enum.map(&( Jetzy.Post.Tag.Repo.create!(&1, context, options)))
      _ -> nil
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
      !value ->
        []
      !value.entities ->
        []
      :else ->
        Enum.map(value.entities, &(&1.status == :active && Noizu.ERP.id(&1.tagged)))
        |> Enum.filter(&(&1))
    end
  end

end



