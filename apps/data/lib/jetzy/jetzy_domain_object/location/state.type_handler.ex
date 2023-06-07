#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.State.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Location.State.Entity} = v, _context, _options), do: v
  def from_partial({:ref, Jetzy.Location.State.Entity, _} = v, _context, _options), do: v
  def from_partial(%{__struct__: _k}, _context, _options), do: nil
  def from_partial(_, _context, _options), do: nil

  #--------------------------------------
  #
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        from_partial(x, context, options) |> Noizu.ERP.ref()
      end
    )
  end
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        from_partial(x, context, options) |> Noizu.ERP.ref()
      end
    )
  end

  #--------------------------------------
  #
  #--------------------------------------
  def pre_update_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        from_partial(x, context, options) |> Noizu.ERP.ref()
      end
    )
  end
  def pre_update_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        from_partial(x, context, options) |> Noizu.ERP.ref()
      end
    )
  end


  def __sphinx_encoded__(field, entity, _indexing, _settings) do
    value = get_in(entity, [Access.key(field)])
    value && Noizu.EctoEntity.Protocol.universal_identifier(value)
  end


end

