#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Interest.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Post.Interest.Entity} = v, _context, _options), do: %{v| __transient__: []}
  def from_partial(%{__struct__: JetzySchema.MSSQL.Post.Interest.Table} = v, context, options) do
    # @todo legacy lookup
    now = options[:current_time] || DateTime.utc_now()
    ts = %Noizu.DomainObject.TimeStamp.Second{
      created_on: v.created_on || now,
      modified_on: v.modified_on || v.created_on || now,
      deleted_on: nil
    }

    interest = JetzySchema.MSSQL.Post.Interest.Table.interest(v, context, options)
    %Jetzy.Post.Interest.Entity{
      post: options[:subject],
      interest: interest,
      weight: options[:weight] || DateTime.to_unix(ts.created_on),
      time_stamp: ts,
      __transient__: [persist?: true]
    }
  end
  def from_partial({:ref, Jetzy.Post.Interest.Entity, _} = ref, _, _), do: ref
  def from_partial(_, _context, _options), do: nil


  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.Post.Interest.Entity} = v, _context, _options), do: v
  def from_partial!(%{__struct__: JetzySchema.MSSQL.Post.Interest.Table} = v, context, options) do
    cond do
      e = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Interest.Table, v.id, context, options) -> e
      :else ->

        now = options[:current_time] || DateTime.utc_now()
        ts = %Noizu.DomainObject.TimeStamp.Second{
          created_on: v.created_on || now,
          modified_on: v.modified_on || v.created_on || now,
          deleted_on: nil
        }

        interest = JetzySchema.MSSQL.Post.Interest.Table.interest!(v, context, options)
        %Jetzy.Post.Interest.Entity{
          post: options[:subject],
          interest: interest,
          weight: options[:weight] || DateTime.to_unix(ts.created_on),
          time_stamp: ts,
        }
    end
  end
  def from_partial!({:ref, Jetzy.Post.Interest.Entity, _} = ref, _, _), do: ref
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
            Jetzy.Post.Interest.Repo.create(v, context, options) |> Noizu.ERP.ref()
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
            Jetzy.Post.Interest.Repo.create!(v, context, options) |> Noizu.ERP.ref()
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
