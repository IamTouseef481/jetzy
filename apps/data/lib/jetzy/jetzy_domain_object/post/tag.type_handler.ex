#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Tag.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  #alias JetzySchema.PG.Post.Tag.Table
  Noizu.DomainObject.noizu_type_handler()


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Post.Tag.Entity} = v, _context, _options), do: v
  def from_partial(%{__struct__: JetzySchema.MSSQL.Post.Tagged.Table} = v, context, options) do
    cond do
      e = Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Post.Tagged.Table, v.id, context, options) -> e
      :else ->
        now = options[:current_time] || DateTime.utc_now()
        ts = %Noizu.DomainObject.TimeStamp.Second{
          created_on: v.created_on || now,
          modified_on: v.modified_on || v.created_on || now,
          deleted_on: nil
        }
        tagged = JetzySchema.MSSQL.Post.Tagged.Table.tagged(v, context, options)
        contact = JetzySchema.MSSQL.Post.Tagged.Table.contact(v, context, options)
        contact = contact && Jetzy.Post.Tag.Contact.Repo.create(contact, context, options)
        (tagged || contact) && %Jetzy.Post.Tag.Entity{
          post: options[:subject],
          tagged: tagged,
          contact: contact,
          tagged_by: options[:owner],
          blocked_by: nil,
          status: JetzySchema.MSSQL.Post.Tagged.Table.status(v, context, options),
          tag_type: :poster,
          time_stamp: ts
        }
    end
  end
  def from_partial(%{contact: contact} = v, context, options) do
    now = options[:current_time] || DateTime.utc_now()
    ts = %Noizu.DomainObject.TimeStamp.Second{
      created_on: v[:created_on] || now,
      modified_on: v[:modified_on] || v[:created_on] || now,
      deleted_on: v[:deleted_on] || nil
    }
    %Jetzy.Post.Tag.Entity{
      post: v[:post] || options[:subject],
      tagged_by: v[:tagged_by] || context.caller,
      blocked_by: v[:blocked_by] || nil,
      tagged: v[:tagged],
      contact: contact,
      status: v[:status] || :sent,
      time_stamp: ts
    }
  end
  def from_partial(%{tagged: tagged} = v, context, options) do
    now = options[:current_time] || DateTime.utc_now()
    ts = %Noizu.DomainObject.TimeStamp.Second{
      created_on: v[:created_on] || now,
      modified_on: v[:modified_on] || v[:created_on] || now,
      deleted_on: v[:deleted_on] || nil
    }
    %Jetzy.Post.Tag.Entity{
      post: v[:post] || options[:subject],
      tagged_by: v[:tagged_by] || context.caller,
      blocked_by: v[:blocked_by] || nil,
      tagged: tagged,
      status: v[:status] || :enabled,
      time_stamp: ts
    }
  end
  def from_partial(_, _context, _options), do: nil

  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.Post.Tag.Entity} = v, _context, _options), do: %{v| __transient__: []}
  def from_partial!(%{__struct__: JetzySchema.MSSQL.Post.Tagged.Table} = v, context, options) do
    cond do
      e = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Tagged.Table, v.id, context, options) -> e
      :else ->
        now = options[:current_time] || DateTime.utc_now()
        ts = %Noizu.DomainObject.TimeStamp.Second{
          created_on: v.created_on || now,
          modified_on: v.modified_on || v.created_on || now,
          deleted_on: nil
        }
        tagged = JetzySchema.MSSQL.Post.Tagged.Table.tagged!(v, context, options)
        contact = JetzySchema.MSSQL.Post.Tagged.Table.contact!(v, context, options)
        contact = contact && Jetzy.Post.Tag.Contact.Repo.create!(contact, context, options)
        (tagged || contact) && %Jetzy.Post.Tag.Entity{
          post: options[:subject],
          tagged: tagged,
          contact: contact,
          tagged_by: options[:owner],
          blocked_by: nil,
          status: JetzySchema.MSSQL.Post.Tagged.Table.status(v, context, options),
          tag_type: :poster,
          time_stamp: ts,
          __transient__: [persist?: true]
        }
    end
  end
  def from_partial!(v, context, options), do: from_partial(v, context, options)



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
        pi = from_partial(x, context, options_b)
        if pi && pi.identifier == nil do
          Jetzy.Post.Tag.Repo.create(pi, context, options)
        else
          pi
        end
      end
    )
  end
  def pre_create_callback!(field, entity, context, options) do
    Amnesia.async(fn -> pre_create_callback(field, entity, context, options) end)
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
