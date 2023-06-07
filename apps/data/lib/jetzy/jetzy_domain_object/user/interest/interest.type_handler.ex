#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Interest.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()
  #----------------------------------
  #
  #----------------------------------


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.User.Interest.Entity} = v, _context, _options), do: %{v| __transient__: []}
  def from_partial(%{__struct__: JetzySchema.MSSQL.User.Interest.Table} = v, context, options) do
    cond do
      e = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Interest.Table, v.id, context, options) -> e
      :else ->

        now = options[:current_time] || DateTime.utc_now()
        ts = %Noizu.DomainObject.TimeStamp.Second{
          created_on: (v.created_on || now) && DateTime.truncate((v.created_on || now), :second),
          modified_on: (v.modified_on || v.created_on || now) && DateTime.truncate((v.modified_on || v.created_on || now), :second),
          deleted_on: nil
        }

        interest = JetzySchema.MSSQL.User.Interest.Table.interest!(v, context, options)
        %Jetzy.User.Interest.Entity{
          user: options[:subject],
          interest: interest,
          visibility: :public,
          time_stamp: ts,
          __transient__: [persist?: true]
        }
    end
  end
  def from_partial({:ref, Jetzy.User.Interest.Entity, _} = ref, _, _), do: ref
  def from_partial(_, _context, _options), do: nil


  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.User.Interest.Entity} = v, _context, _options), do: v
  def from_partial!(%{__struct__: JetzySchema.MSSQL.User.Interest.Table} = v, context, options) do
    cond do
      e = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Interest.Table, v.id, context, options) -> e
      :else ->

        now = options[:current_time] || DateTime.utc_now()
        ts = %Noizu.DomainObject.TimeStamp.Second{
          created_on: v.created_on || now,
          modified_on: v.modified_on || v.created_on || now,
          deleted_on: nil
        }

        interest = JetzySchema.MSSQL.User.Interest.Table.interest!(v, context, options)
        %Jetzy.User.Interest.Entity{
          user: options[:subject],
          interest: interest,
          visibility: :public,
          time_stamp: ts,
          __transient__: [persist?: true]
        }
    end
  end
  def from_partial!({:ref, Jetzy.User.Interest.Entity, _} = ref, _, _), do: ref
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
          v = %{identifier: nil} ->
            Jetzy.User.Interest.Repo.create(v, context, options) |> Noizu.ERP.ref()
          v = %{identifier: _} ->
            Noizu.ERP.ref(v)
          v -> v
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
          v = %{identifier: nil} ->
            Jetzy.User.Interest.Repo.create!(v, context, options) |> Noizu.ERP.ref()
          v = %{identifier: _} ->
            Noizu.ERP.ref(v)
          v -> v
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
