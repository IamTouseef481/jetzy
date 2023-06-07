#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.UniversalIdentifierResolution do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "universal-resolution"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer :redis
  @universal_identifier false
  @universal_lookup false
  @auto_generate false
  defmodule Entity do
    alias Noizu.AdvancedScaffolding.Schema.PersistenceLayer
    require Logger
    use Amnesia
    @nmid_index 116
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :ref
    end

    #----------------------------------------
    # __from_record__
    #----------------------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(_layer, %{identifier: id, ref: ref}, _context, _options) do
      %__MODULE__{identifier: id, ref: ref}
    end
    def __from_record__(_layer, _entity, _context, _options) do
      nil
    end

    #----------------------------------------
    # __from_record__!
    #----------------------------------------
    def __from_record__!(layer, record, context, options \\ nil)
    def __from_record__!(layer, record, context, options) do
      __from_record__(layer, record, context, options)
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
        _ -> Logger.error "Unexpected entity! - #{inspect ref}"
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
          entity && __as_record_type__(layer, entity, context, options)
        _ -> Logger.error "Unexpected entity! - #{inspect ref}"
      end
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      entity && case super(layer, entity, context, options) do
                  record = %{__struct__: JetzySchema.PG.UniversalIdentifierResolution.Table} ->
                    ref = Noizu.ERP.ref(entity.ref)
                    sid = Noizu.EctoEntity.Protocol.ecto_identifier(ref)
                    so = Noizu.EctoEntity.Protocol.source(ref)
                    %JetzySchema.PG.UniversalIdentifierResolution.Table{record|
                      source: so,
                      source_identifier: is_integer(sid) && sid || nil,
                      source_uuid: (is_binary(sid) || is_bitstring(sid)) && sid || nil,
                    }
                  v -> v
                end
    end
    def __as_record_type__(layer, entity, context, options) do
      super(layer, entity, context, options)
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

    def insert(identifier, ref, context, options \\ nil) when is_integer(identifier) and is_tuple(ref) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      %Jetzy.UniversalIdentifierResolution.Entity{
        identifier: identifier,
        ref: ref
      } |> create(context, options)
    end

    def insert!(identifier, ref, context, options \\ nil) when is_integer(identifier) and is_tuple(ref) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      %Jetzy.UniversalIdentifierResolution.Entity{
        identifier: identifier,
        ref: ref
      } |> create!(context, options)
    end


  end

end
