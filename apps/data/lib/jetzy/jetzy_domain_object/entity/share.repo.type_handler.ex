#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Share.Repo.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()
  #-------------------------------
  #
  #-------------------------------
  def compare(nil, nil), do: :eq
  def compare(nil, _), do: :neq
  def compare(_, nil), do: :neq
  def compare(a, b), do: a.entities == b.entities

  #----------------------
  # from_partial
  #----------------------
  def from_partial(%{__struct__: Jetzy.Entity.Share.Repo} = v, _context, _options), do: v
  def from_partial(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(Jetzy.Entity.Share.TypeHandler.from_partial(&1, context, options)))
               |> Enum.filter(&(&1))
    %Jetzy.Entity.Share.Repo{entities: entities, length: length(entities)}
  end
  def from_partial(_, _context, _options) do
    %Jetzy.Entity.Share.Repo{entities: [], length: 0}
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = update_in(options || [], [:subject], &(&1 || Noizu.ERP.ref(entity)))
        shares = from_partial(x, context, options_b)
        entities = Enum.map(shares.entities || [], fn
          (%{identifier: nil} = s) -> Jetzy.Entity.Share.Repo.create(s, context, options)
          (v) -> v
        end)
        %Jetzy.Entity.Share.Repo{shares| entities: entities}
      end
    )
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = update_in(options || [], [:subject], &(&1 || Noizu.ERP.ref(entity)))
        shares = from_partial(x, context, options_b)
        entities = Enum.map(shares.entities || [], fn
          (%{identifier: nil} = s) -> Jetzy.Entity.Share.Repo.create!(s, context, options)
          (v) -> v
        end)
        %Jetzy.Entity.Share.Repo{shares| entities: entities}
      end
    )
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


end

