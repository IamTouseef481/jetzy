#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Contact.Channel.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()



  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Entity.Contact.Channel.Entity} = v, _context, _options), do: %{v| __transient__: []}
  def from_partial(%{} = v, context, options) do
    subject_ref = options[:subject] |> Noizu.ERP.ref()
    %Jetzy.Entity.Contact.Channel.Entity{
      subject: subject_ref,
      status: :active,
      channel_type: v[:channel_type],
      channel: v,
      weight: v[:weight] || 0,
      moderation: %Jetzy.ModerationDetails{},
      time_stamp: v[:time_stamp]
    }
  end
  def from_partial({:ref, Jetzy.Entity.Contact.Channel.Entity, _} = ref, _, _), do: ref
  def from_partial(_, _context, _options), do: nil


  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.Entity.Contact.Channel.Entity} = v, context, options), do: v
  def from_partial!(%{} = v, context, options) do
    subject_ref = options[:subject] |> Noizu.ERP.ref()
    %Jetzy.Entity.Contact.Channel.Entity{
      subject: subject_ref,
      status: :active,
      channel_type: v[:channel_type],
      channel: v,
      weight: v[:weight] || 0,
      moderation: %Jetzy.ModerationDetails{},
      time_stamp: v[:time_stamp]
    }
  end
  def from_partial!({:ref, Jetzy.Entity.Contact.Channel.Entity, _} = ref, _, _), do: ref
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
            Jetzy.Entity.Contact.Channel.Repo.create(v, context, options) |> Noizu.ERP.ref()
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
            Jetzy.Entity.Contact.Channel.Repo.create!(v, context, options) |> Noizu.ERP.ref()
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

