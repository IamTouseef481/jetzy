
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Share.RollUp do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-share-rollup"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate false
  defmodule Entity do
    @nmid_index 92
    @universal_identifier false
    require Logger
    use Amnesia
    Noizu.DomainObject.noizu_entity do
      identifier :ref

      public_field :subject

      public_field :tally

      public_field :synchronized_on, nil,  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end


    #-----------------------------------
    # __as_record__
    #-----------------------------------
    def __as_record__(table, ref, context, options) when is_atom(table) do
      layer = __persistence__(:table)[table]
      layer && __as_record__(layer, ref, context, options)
    end
    def __as_record__(layer = %{__struct__: PersistenceLayer}, ref, context, options) do
      case ref do
        entity = %{__struct__: __MODULE__} -> __as_record_type__(layer, entity, context, options)
        {:ref, _e, _} ->
          entity = entity(ref, options)
          entity && __as_record_type__( layer, entity, context, options)
        _ -> Logger.error "#{__ENV__.file}:#{__ENV__.line} - Unexpected entity! - #{inspect ref}"
      end
    end

    #-----------------------------------
    # __as_record__!
    #-----------------------------------
    def __as_record__!(table, ref, context, options) when is_atom(table) do
      layer = __persistence__(:table)[table]
      layer && __as_record__!(layer, ref, context, options)
    end
    def __as_record__!(layer = %{__struct__: PersistenceLayer}, ref, context, options) do
      case ref do
        entity = %{__struct__: __MODULE__} -> __as_record_type__!(layer, entity, context, options)
        {:ref, _e, _} ->
          entity = entity!(ref, options)
          entity && __as_record_type__!(layer, entity, context, options)
        _ -> Logger.error "#{__ENV__.file}:#{__ENV__.line} - Unexpected entity! - #{inspect ref}"
      end
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      case entity && super(layer, entity, context, options) do
        record = %{__struct__: JetzySchema.PG.Entity.Comment.RollUp.Table} ->
          sid = Noizu.EctoEntity.Protocol.universal_identifier(entity.subject) || Noizu.EctoEntity.Protocol.universal_identifier(entity.identifier)
          so =  Noizu.EctoEntity.Protocol.source(entity.subject) || Noizu.EctoEntity.Protocol.source(entity.identifier)
          %{record|
            identifier: sid,
            subject_source: so,
          }
        v -> v
      end
    end
    def __as_record_type__(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    def ecto_identifier({:ecto_identifier, id}), do: id
    def ecto_identifier({:ref, __MODULE__, id}) do
      Noizu.EctoEntity.Protocol.universal_identifier(id)
    end
    def ecto_identifier(entity) do
      Noizu.EctoEntity.Protocol.universal_identifier(entity)
    end

    #----------------------------------------
    # __as_record_type__!
    #----------------------------------------
    def __as_record_type__!(layer, entity, context, options \\ nil)
    def __as_record_type__!(layer, entity, context, options) do
      Amnesia.async fn ->
        __as_record_type__(layer, entity, context, options)
      end
    end

  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end

    def pre_create_callback!(entity, context, options) do
      entity = %{entity| identifier: Noizu.ERP.ref(entity.subject)}
      super(entity, context, options)
    end

    def pre_create_callback(entity, context, options) do
      entity = %{entity| identifier: Noizu.ERP.ref(entity.subject)}
      super(entity, context, options)
    end

  end

end
