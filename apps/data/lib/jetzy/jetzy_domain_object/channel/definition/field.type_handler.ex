#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Definition.Field.TypeHandler do
    require  Noizu.DomainObject

    alias Jetzy.Channel.Definition.Field.Repo
    alias Jetzy.Channel.Definition.Field.Entity

    #--------------------------------------
    # from_partial
    #--------------------------------------
    def from_partial(%{__struct__: Entity} = v, _, _), do: v
    def from_partial(%{} = v, _, options) do
        channel_definition = options[:subject] |> Noizu.ERP.ref()
        %Entity{
            channel_definition: channel_definition,
            field_type: v[:field_type],
            validation: v[:validation],
            weight: v[:weight] || 0,
            description: v[:description],
            modified_on: v[:modified_on] || options[:current_time] || DateTime.utc_now()
        }
    end
    def from_partial({:ref, Entity, _} = ref, _, _), do: ref
    def from_partial(_, _, _), do: nil

    #--------------------------------------
    # from_partial!
    #--------------------------------------
    def from_partial!(%{__struct__: Entity} = v, _, _), do: v
    def from_partial!(%{} = v, _, options) do
        channel_definition = options[:subject] |> Noizu.ERP.ref()
        %Entity{
            channel_definition: channel_definition,
            field_type: v[:field_type],
            validation: v[:validation],
            weight: v[:weight] || 0,
            description: v[:description],
            modified_on: v[:modified_on] || options[:current_time] || DateTime.utc_now()
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
