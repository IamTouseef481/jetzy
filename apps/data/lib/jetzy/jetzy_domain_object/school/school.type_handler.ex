defmodule Jetzy.School.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()

  #--------------------------------------
  # from_partial
  #--------------------------------------
  def from_partial(%{__struct__: Jetzy.School.Entity} = v, _context, options), do: v
  def from_partial(%{name: name}, context, options) do
    now = options[:current_time] || DateTime.utc_now()
    %Jetzy.School.Entity{
      name: name,
      description: %{title: name},
      time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now),
    }
  end
  def from_partial(_entity, _context, _options) do
    nil
  end

  #--------------------------------------
  # from_partial!
  #--------------------------------------
  def from_partial!(%{__struct__: Jetzy.School.Entity} = v, _context, options), do: v
  def from_partial!(%{name: name}, context, options) do
    now = options[:current_time] || DateTime.utc_now()
    %Jetzy.School.Entity{
      name: name,
      description: %{title: name},
      time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now),
    }
  end
  def from_partial!(_entity, _context, _options) do
    nil
  end

  #--------------------------------------
  #
  #--------------------------------------
  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        pi = from_partial(x, context, options)
        if pi && pi.identifier == nil do
          Jetzy.School.Repo.create(pi, context, options)
        else
          pi
        end |> Noizu.ERP.ref()
      end
    )
  end
  def pre_create_callback!(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (x) ->
        pi = from_partial!(x, context, options)
        if pi && pi.identifier == nil do
          Jetzy.School.Repo.create!(pi, context, options)
        else
          pi
        end |> Noizu.ERP.ref()
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


  #-------------------------------
  #
  #-------------------------------
  def __sphinx_field__(), do: true
  def __sphinx_expand_field__(field, indexing, _settings) do
    indexing = update_in(indexing, [:from], &(&1 || field))
    [
      {:"#{field}_name", __MODULE__, put_in(indexing, [:sub], :name)},
    ]
  end
  def __sphinx_has_default__(_field, _indexing, _settings), do: false
  def __sphinx_default__(_field, _indexing, _settings), do: nil
  def __sphinx_bits__(_field, _indexing, _settings), do: :auto
  def __sphinx_encoding__(_field, _indexing, _settings), do: :field
  def __sphinx_encoded__(_field, entity, indexing, _settings) do
    value = get_in(entity, [Access.key(indexing[:from])])
            |> Noizu.ERP.entity!()
    cond do
      value == nil -> ""
      indexing[:sub] == :name -> "#{value.name}"
    end
  end
end
