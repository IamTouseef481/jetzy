#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Interactions.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()


  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.Entity.Interactions.Entity} = v, _context, _options), do: v
  def from_partial(%{} = partial, _context, options) do
    now = options[:current_time] || DateTime.utc_now()
    %Jetzy.Entity.Interactions.Entity{
      comments: partial[:comments] || 0,
      like: partial[:like] || 0,
      dislike: partial[:dislike] || 0,
      heart: partial[:heart] || 0,
      angry: partial[:angry] || 0,
      sad: partial[:sad] || 0,
      laugh: partial[:laugh] || 0,
      confused: partial[:confused] || 0,
      comfort: partial[:comfort] || 0,
      reaction_09: partial[:reaction_09] || 0,
      reaction_10: partial[:reaction_10] || 0,
      synchronized_on: partial[:synchronized_on] || now,
      modified_on: partial[:modified_on] || now,
    }
  end
  def from_partial({:ref, Jetzy.Entity.Interactions, _} = v, _context, _options), do: v
  def from_partial(_, context, options) do
    from_partial(%{}, context, options)
  end

  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case from_partial(v, context, options) do
          v = %{identifier: nil} -> %{v| identifier: Noizu.ERP.ref(entity)} |> Jetzy.Entity.Interactions.Repo.create!(context, options) |> Jetzy.Entity.Interactions.Entity.ref()
          v = %{identifier: _} -> v |> Jetzy.Entity.Interactions.Repo.create!(context, options) |> Jetzy.Entity.Interactions.Entity.ref()
          v -> v
        end
      end
    )
  end
  def pre_create_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      pre_create_callback(field, entity, context, options)
    end
  end


  def pre_update_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        case from_partial(v, context, options) do
          v = %{identifier: nil} -> %{v| identifier: Noizu.ERP.ref(entity)} |> Jetzy.Entity.Interactions.Repo.create!(context, options) |> Jetzy.Entity.Interactions.Entity.ref()
          v = %{identifier: _} -> v |> Jetzy.Entity.Interactions.Repo.update!(context, options) |> Jetzy.Entity.Interactions.Entity.ref()
          v -> v
        end
      end
    )
  end
  def pre_update_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      pre_update_callback(field, entity, context, options)
    end
  end

end

