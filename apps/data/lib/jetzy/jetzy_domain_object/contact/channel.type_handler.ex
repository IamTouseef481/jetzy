#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Contact.Channel.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()
  alias Jetzy.Contact.Channel.Repo
  alias Jetzy.Contact.Channel.Entity

  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Entity} = v, _, _), do: v
  def from_partial(%{} = v, context, options) do
    channel_definition = Jetzy.Channel.Definition.Repo.by_type(v[:channel_type], context, options)
    %Entity{
      channel_definition: channel_definition,
      description: nil,
      fields: v,
      moderation: %Jetzy.ModerationDetails{},
      time_stamp: v[:time_stamp]
    }
  end
  def from_partial({:ref, Entity, _} = ref, _, _), do: ref
  def from_partial(_, _, _), do: nil

  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Entity} = v, _, _), do: v
  def from_partial!(%{} = v, context, options) do
    channel_definition = Jetzy.Channel.Definition.Repo.by_type!(v[:channel_type], context, options)
    %Entity{
      channel_definition: channel_definition,
      description: nil,
      fields: v,
      moderation: %Jetzy.ModerationDetails{},
      time_stamp: v[:time_stamp]
    }
  end
  def from_partial!({:ref, Entity, _} = ref, _, _), do: ref
  def from_partial!(_, _, _), do: nil



  #--------------------------------------
  #
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      x = case from_partial(x, context, options_b) do
            x = %{identifier: nil} -> Repo.create(x, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
            x -> x
          end
      cond do
        is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) -> put_in(entity, [Access.key(:__transient__), field], x)
        :else -> entity
      end |> put_in([Access.key(field)], Noizu.ERP.ref(x))
    else
      entity
    end
  end
  def pre_create_callback!(field, entity, context, options) do
    if x = get_in(entity, [Access.key(field)]) do
      options = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
      options_b = (options || []) |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
      x = case from_partial!(x, context, options_b) do
            x = %{identifier: nil} -> Repo.create!(x, context, options) |> put_in([Access.key(:__transient__), :persist?], true)
            x -> x
          end
      cond do
        is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) -> put_in(entity, [Access.key(:__transient__), field], x)
        :else -> entity
      end |> put_in([Access.key(field)], Noizu.ERP.ref(x))
    else
      entity
    end
  end

  def post_create_callback(field, entity, context, options) do
    {x, entity} = pop_in(entity, [Access.key(:__transient__), field])
    cond do
      is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        Repo.create!(x, context, options)
      :else -> :nop
    end
    entity
  end

  def post_create_callback!(field, entity, context, options) do
    {x, entity} = pop_in(entity, [Access.key(:__transient__), field])
    cond do
      is_struct(x) && get_in(x, [Access.key(:__transient__), :persist?]) ->
        options = (options || [])
                  |> update_in([Data.Repo], &(put_in(&1||[], [:cascade?], true)))
                  |> put_in([:cascade?], false)
                  |> put_in([:override_identifier], true)
        Repo.create!(x, context, options)
      :else -> :nop
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
end
