#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Share.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()

  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Entity.Share.Entity} = v, context, options) do
    cond do
      v.__transient__[:late_binding] ->
        Enum.map(Map.from_struct(v),
          fn
            ({p,{:bind, b}}) -> {p,b}
            (_) -> nil
          end)
        |> Enum.filter(&(&1))
        |> Enum.reduce(v, fn({p,b}, acc) ->
          case b do
            b when is_function(b, 3) -> put_in(acc, [Access.key(p)], b.(acc, context, options))
            [:options|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(options, ip))
            [:context|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(context, ip))
            [:partial|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(acc, ip))
          end
        end)
      :else -> v
    end
  end
  def from_partial(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = v, context, options) do
    %Jetzy.Entity.Share.Entity{
      status: :active,
      subject: options[:subject] || Jetzy.Post.Repo.by_legacy(v.post_id, context, options),
      share_type: JetzySchema.MSSQL.Post.Private.Table.share_type(v, context, options),
      share_with: JetzySchema.MSSQL.Post.Private.Table.share_with(v, context, options),
      time_stamp: JetzySchema.MSSQL.Post.Private.Table.time_stamp(v, context, options),
    }
  end
  def from_partial(%{__struct__: _k}, _context, _options), do: nil
  def from_partial(%{share_type: share_type} = v, _context, options) do
    now = options[:current_time] || DateTime.utc_now()
    ts = %Noizu.DomainObject.TimeStamp.Second{
      created_on: v[:created_on] || now,
      modified_on: v[:modified_on] || v[:created_on] || now,
      deleted_on: v[:deleted_on] || nil
    }
    subject = v[:subject] || options[:subject] || throw "Subject Required"
    %Jetzy.Entity.Share.Entity{
      status: v[:status] || :active,
      subject: subject,
      share_type: share_type,
      share_with: v[:share_with],
      time_stamp: ts
    }
  end
  def from_partial(_, _context, _options), do: nil


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.Entity.Share.Entity} = v, context, options) do
    cond do
      v.__transient__[:late_binding] ->
        Enum.map(Map.from_struct(v),
          fn
            ({p,{:bind, b}}) -> {p,b}
            (_) -> nil
          end)
        |> Enum.filter(&(&1))
        |> Enum.reduce(v, fn({p,b}, acc) ->
          case b do
            b when is_function(b, 3) -> put_in(acc, [Access.key(p)], b.(acc, context, options))
            [:options|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(options, ip))
            [:context|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(context, ip))
            [:partial|ip] when is_list(ip) -> put_in(acc, [Access.key(p)], get_in(acc, ip))
          end
        end)
      :else -> v
    end
  end
  def from_partial!(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = v, context, options) do
    %Jetzy.Entity.Share.Entity{
      status: :active,
      subject: options[:subject] || Jetzy.Post.Repo.by_legacy!(v.post_id, context, options),
      share_type: JetzySchema.MSSQL.Post.Private.Table.share_type!(v, context, options),
      share_with: JetzySchema.MSSQL.Post.Private.Table.share_with!(v, context, options),
      time_stamp: JetzySchema.MSSQL.Post.Private.Table.time_stamp!(v, context, options),
    }
  end
  def from_partial!(%{__struct__: _k}, _context, _options), do: nil
  def from_partial!(%{share_type: share_type} = v, _context, options) do
    now = options[:current_time] || DateTime.utc_now()
    ts = %Noizu.DomainObject.TimeStamp.Second{
      created_on: v[:created_on] || now,
      modified_on: v[:modified_on] || v[:created_on] || now,
      deleted_on: v[:deleted_on] || nil
    }
    subject = v[:subject] || options[:subject] || throw "Subject Required"
    %Jetzy.Entity.Share.Entity{
      status: v[:status] || :active,
      subject: subject,
      share_type: share_type,
      share_with: v[:share_with],
      time_stamp: ts
    }
  end
  def from_partial!(_, _context, _options), do: nil


  #--------------------------------------
  # pre_create_callback
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = put_in(options || [], [:subject], Noizu.ERP.ref(entity))
        if share = from_partial(x, context, options_b) do
          share.identifier == nil && Jetzy.Entity.Share.Repo.create(share, context, options) || share
        end
      end
    )
  end

  #--------------------------------------
  # pre_create_callback!
  #--------------------------------------
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = put_in(options || [], [:subject], Noizu.ERP.ref(entity))
        if share = from_partial!(x, context, options_b) do
          share.identifier == nil && Jetzy.Entity.Share.Repo.create!(share, context, options) || share
        end
      end
    )
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = put_in(options || [], [:subject], Noizu.ERP.ref(entity))
        if share = from_partial(x, context, options_b) do
          share != x && Jetzy.Entity.Share.Repo.update(share, context, options) || share
        end
      end
    )
  end


  #-------------------------------
  #
  #-------------------------------
  def pre_update_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = put_in(options || [], [:subject], Noizu.ERP.ref(entity))
        if share = from_partial!(x, context, options_b) do
          share != x && Jetzy.Entity.Share.Repo.update!(share, context, options) || share
        end
      end
    )
  end

end
