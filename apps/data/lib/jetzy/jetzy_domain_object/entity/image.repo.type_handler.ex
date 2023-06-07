#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Image.Repo.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()

  def compare(nil, nil), do: :eq
  def compare(nil, _), do: :neq
  def compare(_, nil), do: :neq
  def compare(a, b), do: a.entities == b.entities

  #----------------------
  # from_partial!
  #----------------------
  def from_partial!(%{__struct__: Jetzy.Entity.Image.Repo, entities: entities}, context, options) do
    entities = Enum.map(entities || [], &(Jetzy.Entity.Image.TypeHandler.from_partial!(&1, context, options)))
               |> Enum.filter(&(&1))
    %Jetzy.Entity.Image.Repo{entities: entities, length: length(entities)}
  end
  def from_partial!(v, context, options) when is_list(v) do
    entities = Enum.map(v, &(Jetzy.Entity.Image.TypeHandler.from_partial!(&1, context, options)))
               |> Enum.filter(&(&1))
    %Jetzy.Entity.Image.Repo{entities: entities, length: length(entities)}
  end
  def from_partial!(_, _context, _options) do
    %Jetzy.Entity.Image.Repo{entities: [], length: 0}
  end

  #----------------------
  # from_partial
  #----------------------
  def from_partial(%{__struct__: Jetzy.Entity.Image.Repo, entities: entities}, context, options) do
    v = Enum.map(entities || [], &(Jetzy.Entity.Image.TypeHandler.from_partial(&1, context, options)))
        |> Enum.filter(&(&1))
    %Jetzy.Entity.Image.Repo{entities: v, length: length(v)}
  end
  def from_partial(v, context, options) when is_list(v) do
    v = Enum.map(v, &(Jetzy.Entity.Image.TypeHandler.from_partial(&1, context, options)))
        |> Enum.filter(&(&1))
    %Jetzy.Entity.Image.Repo{entities: v, length: length(v)}
  end
  def from_partial(_, _context, _options) do
    %Jetzy.Entity.Image.Repo{entities: [], length: 0}
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
        media = from_partial(x, context, options_b)
        entities = Enum.map(media && media.entities || [], fn
          (%{identifier: nil} = s) -> Jetzy.Entity.Image.Repo.create(s, context, options)
          (v) -> v
        end)
        %Jetzy.Entity.Image.Repo{media| entities: entities}
      end
    )
  end

  #-------------------------------
  #
  #-------------------------------
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        options_b = (options || [])
                    |> update_in([:subject], &(&1 || Noizu.ERP.ref(entity)))
        media = from_partial!(x, context, options_b)
        entities = Enum.map(media && media.entities || [], fn
          (%{identifier: nil} = s) -> Jetzy.Entity.Image.Repo.create!(s, context, options)
          (v) -> v
        end)
        %Jetzy.Entity.Image.Repo{media| entities: entities}
      end
    )
  end

  def from_json(format, field, json, context, options) do
    cond do
      v = is_list(json[Atom.to_string(field)]) && json[Atom.to_string(field)] ->
        Enum.map(v, &(Jetzy.Entity.Image.TypeHandler.from_json(format, :media, %{"media" => &1}, context, options)))
        |> Enum.filter(&(&1))
      :else -> []
    end
  end
end

