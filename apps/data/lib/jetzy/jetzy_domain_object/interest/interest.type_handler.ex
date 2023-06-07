#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Interest.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()

  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Interest.Entity} = v, _context, _options), do: %{v| __transient__: []}
  def from_partial(%{__struct__: JetzySchema.MSSQL.Interest.Table} = v, context, options) do
    Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Interest.Table, v.id, context, options)
  end
  def from_partial({:ref, Jetzy.Interest.Entity, _} = ref, _, _), do: ref
  def from_partial(_, _context, _options), do: nil


  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.Interest.Entity} = v, _context, _options), do: v
  def from_partial!(%{__struct__: JetzySchema.MSSQL.Interest.Table} = v, context, options) do
    Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Interest.Table, v.id, context, options)
  end
  def from_partial!({:ref, Jetzy.Interest.Entity, _} = ref, _, _), do: ref
  def from_partial!(_, _context, _options), do: nil




  #--------------------------------------
  #
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
        case from_partial(x, context, options_b) do
          i = %{identifier: nil} -> Jetzy.Interest.Repo.create(i, context, options)
          i -> i
        end
      end
    )
  end
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
        case from_partial!(x, context, options_b) do
          i = %{identifier: nil} -> Jetzy.Interest.Repo.create!(i, context, options)
          i -> i
        end
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
