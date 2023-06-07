#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.LegacyResolution do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "legacy-resolution"
  @persistence_layer {JetzySchema.Database, [cascade?: true, sync: true]}
  @persistence_layer {JetzySchema.PG.Repo, [cascade?: true, sync: true]}
  @universal_identifier false
  @universal_lookup false
  @auto_generate true
  @generate_reference_type :basic_ref
  @nmid_bare :node
  defmodule Entity do
    use Amnesia
    @nmid_index 96
    require Logger
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :ref

      public_field :legacy_source
      public_field :legacy_integer_identifier
      public_field :legacy_guid_identifier
      public_field :legacy_string_identifier
      public_field :legacy_sub_identifier
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
        {:ref, __MODULE__, _} ->
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
        {:ref, __MODULE__, _} ->
          entity = entity!(ref, options)
          __as_record_type__(layer, entity, context, options)
        _ -> Logger.error "#{__ENV__.file}:#{__ENV__.line} - Unexpected entity! - #{inspect ref}"
      end
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      case super(layer, entity, context, options) do
        record = %{__struct__: JetzySchema.PG.LegacyResolution.Table} ->
          ref = {:ref, m, _} = entity.ref
          sid = Noizu.EctoEntity.Protocol.ecto_identifier(ref)
          so = Noizu.EctoEntity.Protocol.source(ref)
          %JetzySchema.PG.LegacyResolution.Table{record|
               source: so,
               source_identifier: sid,
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
    import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do

    end

    #---------------------------------------
    #
    #---------------------------------------
    def insert(ref, legacy_source, legacy_identifier, context, options \\ nil)
    def insert(_ref, _legacy_source, nil, _context, _options), do: nil
    def insert(ref, legacy_source, %Decimal{} = legacy_identifier, context, options), do: insert(ref, legacy_source, Decimal.to_integer(legacy_identifier), context, options)
    def insert(ref, legacy_source, legacy_identifier, context, options) when is_integer(legacy_identifier) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        legacy_source: legacy_source,
        legacy_integer_identifier: legacy_identifier,
      }
      |> create(context, options)
    end


    #---------------------------------------
    #
    #---------------------------------------
    def insert!(ref, legacy_source, legacy_identifier, context, options \\ nil)
    def insert!(_ref, _legacy_source, nil, _context, _options), do: nil
    def insert!(ref, legacy_source, %Decimal{} = legacy_identifier, context, options), do: insert!(ref, legacy_source, Decimal.to_integer(legacy_identifier), context, options)
    def insert!(ref, legacy_source, legacy_identifier, context, options) when is_integer(legacy_identifier) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
                             ref: Noizu.ERP.ref(ref),
                             legacy_source: legacy_source,
                             legacy_integer_identifier: legacy_identifier,
                           }
                           |> create!(context, options)
    end


    #---------------------------------------
    #
    #---------------------------------------
    def remove_by_ref!(ref, legacy_source, context, options \\ nil)
    def remove_by_ref!(ref, legacy_source, context, options) do
      if Noizu.ERP.id(ref) do
        ref = {:ref, type, uid} = Noizu.ERP.ref(ref)
        # purge mnesia
        JetzySchema.Database.LegacyResolution.Table.match!([ref: ref,  legacy_source: legacy_source])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        
        # TODO should be
        #           sid = Noizu.EctoEntity.Protocol.ecto_identifier(ref)
        #          so = Noizu.EctoEntity.Protocol.source(ref)
        
        source = cond do
                   s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                   :else -> type
                 end
        query = from r in JetzySchema.PG.LegacyResolution.Table,
                     where: r.legacy_source == ^legacy_source,
                     where: r.source == ^source,
                     where: r.source_identifier == ^uid,
                     select: r
        JetzySchema.PG.Repo.delete_all(query)
        :ok
      end
    end

    def remove_by_ref_and_id!(ref, legacy_source, legacy_identifier, context, options \\ nil)
    def remove_by_ref_and_id!(ref, legacy_source, legacy_identifier, context, options) when is_integer(legacy_identifier) do
      if Noizu.ERP.id(ref) do
        ref = {:ref, type, uid} = Noizu.ERP.ref(ref)
        # purge mnesia
        JetzySchema.Database.LegacyResolution.Table.match!([ref: ref,  legacy_source: legacy_source, legacy_integer_identifier: legacy_identifier])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        source = cond do
                   s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                   :else -> type
                 end
        query = from r in JetzySchema.PG.LegacyResolution.Table,
                     where: r.legacy_source == ^legacy_source,
                     where: r.legacy_integer_identifier == ^legacy_identifier,
                     where: r.source == ^source,
                     where: r.source_identifier == ^uid,
                     select: r
        JetzySchema.PG.Repo.delete_all(query)
        :ok
      end
    end
    def remove_by_ref_and_id!(ref, legacy_source, legacy_identifier, context, options) when is_bitstring(legacy_identifier) do
      if Noizu.ERP.id(ref) do
        ref = {:ref, type, uid} = Noizu.ERP.ref(ref)
        # purge mnesia
        JetzySchema.Database.LegacyResolution.Table.match!([ref: ref,  legacy_source: legacy_source, legacy_guid_identifier: legacy_identifier])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        source = cond do
                   s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                   :else -> type
                 end
        query = from r in JetzySchema.PG.LegacyResolution.Table,
                     where: r.legacy_source == ^legacy_source,
                     where: r.legacy_guid_identifier == ^legacy_identifier,
                     where: r.source == ^source,
                     where: r.source_identifier == ^uid,
                     select: r
        JetzySchema.PG.Repo.delete_all(query)
        :ok
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def remove!(_, legacy_source, legacy_identifier, context, options \\ nil)
    def remove!(_, _legacy_source, nil, _context, _options), do: nil
    def remove!(type, legacy_source, %Decimal{} = legacy_identifier, context, options), do: remove!(type, legacy_source, Decimal.to_integer(legacy_identifier), context, options)
    def remove!(type, legacy_source, legacy_identifier, context, options) when is_integer(legacy_identifier) do
      # purge mnesia
      JetzySchema.Database.LegacyResolution.Table.match!([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_integer_identifier: legacy_identifier])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
      end)
      # purge redis

      # purge pg.
      source = cond do
                 s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                 :else -> type
               end
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.legacy_integer_identifier == ^legacy_identifier,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
      :ok
    end
    def remove!(type, legacy_source, legacy_identifier, context, options) when is_bitstring(legacy_identifier) do
      # purge mnesia
      JetzySchema.Database.LegacyResolution.Table.match!([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_guid_identifier: legacy_identifier])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
      end)
      # purge redis

      # purge pg.
      source = cond do
                 s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                 :else -> type
               end
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.legacy_guid_identifier == ^legacy_identifier,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
      :ok
    end



    #---------------------------------------
    #
    #---------------------------------------
    def insert_guid(ref, legacy_source, legacy_identifier, context, options \\ nil)
    def insert_guid(_ref, _legacy_source, nil, _context, _options), do: nil
    def insert_guid(ref, legacy_source, legacy_identifier, context, options) when is_bitstring(legacy_identifier) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        legacy_source: legacy_source,
        legacy_guid_identifier: legacy_identifier,
      } |> create(context, options)
    end

    #---------------------------------------
    #
    #---------------------------------------
    def insert_guid!(ref, legacy_source, legacy_identifier, context, options \\ nil)
    def insert_guid!(_ref, _legacy_source, nil, _context, _options), do: nil
    def insert_guid!(ref, legacy_source, legacy_identifier, context, options) when is_bitstring(legacy_identifier) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        legacy_source: legacy_source,
        legacy_guid_identifier: legacy_identifier,
      } |> create!(context, options)
    end

    #---------------------------------------
    #
    #---------------------------------------
    def insert_identifier_and_guid(ref, legacy_source, legacy_identifier, legacy_guid, context, options \\ nil)
    def insert_identifier_and_guid(ref, legacy_source, %Decimal{} = legacy_identifier, legacy_guid, context, options), do: insert_identifier_and_guid(ref, legacy_source, Decimal.to_integer(legacy_identifier), legacy_guid, context, options)
    def insert_identifier_and_guid(ref, legacy_source, legacy_identifier, legacy_guid, context, options) when is_integer(legacy_identifier) or is_bitstring(legacy_guid) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        legacy_source: legacy_source,
        legacy_integer_identifier: legacy_identifier,
        legacy_guid_identifier: legacy_guid,
      } |> create(context, options)
    end
    def insert_identifier_and_guid(_ref, _legacy_source, _legacy_identifier, _legacy_guid, _context, _options), do: nil

    #---------------------------------------
    #
    #---------------------------------------
    def insert_identifier_and_guid!(ref, legacy_source, legacy_identifier, legacy_guid, context, options \\ nil)
    def insert_identifier_and_guid!(ref, legacy_source, %Decimal{} = legacy_identifier, legacy_guid, context, options), do: insert_identifier_and_guid!(ref, legacy_source, Decimal.to_integer(legacy_identifier), legacy_guid, context, options)
    def insert_identifier_and_guid!(ref, legacy_source, legacy_identifier, legacy_guid, context, options) when is_integer(legacy_identifier) or is_bitstring(legacy_guid) do
      Noizu.ERP.id(ref) && %Jetzy.LegacyResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        legacy_source: legacy_source,
        legacy_integer_identifier: legacy_identifier,
        legacy_guid_identifier: legacy_guid,
      } |> create!(context, options)
    end
    def insert_identifier_and_guid!(_ref, _legacy_source, _legacy_identifier, _legacy_guid, _context, _options), do: nil


    def remove_identifier_and_guid!(type, legacy_source, legacy_identifier, legacy_guid, context, options \\ nil)
    def remove_identifier_and_guid!(type, legacy_source, %Decimal{} = legacy_identifier, legacy_guid, context, options), do: remove_identifier_and_guid!(type, legacy_source, Decimal.to_integer(legacy_identifier), legacy_guid, context, options)
    def remove_identifier_and_guid!(type, legacy_source, legacy_identifier, legacy_guid, context, options) when is_integer(legacy_identifier) or is_bitstring(legacy_guid) do

      JetzySchema.Database.LegacyResolution.Table.match!([
        ref: {:ref, type, :_},
        legacy_source: legacy_source,
        legacy_integer_identifier: legacy_identifier,
        legacy_guid_identifier: legacy_guid,
      ])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.LegacyResolution.Repo.delete!(%Jetzy.LegacyResolution.Entity{identifier: record.identifier}, context, options)
      end)


      # purge redis

      # purge pg.
      source = cond do
                 s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                 :else -> type
               end
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.legacy_integer_identifier == ^legacy_identifier,
                   where: r.legacy_guid_identifier == ^legacy_guid,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
      :ok
    end
    def remove_identifier_and_guid!(_type, _legacy_source, _legacy_identifier, _legacy_guid, _context, _options), do: nil









    def update_identifier_and_guid!(ref, legacy_source, legacy_identifier, legacy_guid, context, options \\ nil)
    def update_identifier_and_guid!(ref, legacy_source, %Decimal{} = legacy_identifier, legacy_guid, context, options), do: insert_identifier_and_guid!(ref, legacy_source, Decimal.to_integer(legacy_identifier), legacy_guid, context, options)
    def update_identifier_and_guid!(ref, legacy_source, legacy_identifier, legacy_guid, context, options) when is_integer(legacy_identifier) or is_bitstring(legacy_guid) do
      cond do
        Noizu.ERP.id(ref) ->
          case JetzySchema.Database.LegacyResolution.Table.match!([legacy_source: legacy_source, legacy_integer_identifier: legacy_identifier]) |> Amnesia.Selection.values() do
            [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] ->
              %{entity.entity| ref: Noizu.ERP.ref(ref)} |> update!(context, options)
            _ ->
              %Jetzy.LegacyResolution.Entity{
                ref: Noizu.ERP.ref(ref),
                legacy_source: legacy_source,
                legacy_integer_identifier: legacy_identifier,
                legacy_guid_identifier: legacy_guid,
              } |> create!(context, options)
          end
        :else -> nil
      end
    end
    def update_identifier_and_guid!(_ref, _legacy_source, _legacy_identifier, _legacy_guid, _context, _options), do: nil



    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid(type, identifier, context, options \\ nil)
    def by_legacy_guid(type, identifier, context, options) when is_bitstring(identifier) do
      cond do
        ref = by_legacy_guid__mnesia(type, identifier, context, options) -> ref
        ref = by_legacy_guid__redis(type, identifier, context, options) -> ref
        ref = by_legacy_guid__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid!(type, identifier, context, options \\ nil)
    def by_legacy_guid!(type, identifier, context, options) when is_bitstring(identifier) do
      cond do
        ref = by_legacy_guid__mnesia!(type, identifier, context, options) -> ref
        ref = by_legacy_guid__redis(type, identifier, context, options) -> ref
        ref = by_legacy_guid__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid__mnesia!(type, identifier, context, options \\ nil)
    def by_legacy_guid__mnesia!(type, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match!([legacy_source: type, legacy_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid__mnesia(type, identifier, context, options \\ nil)
    def by_legacy_guid__mnesia(type, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match([legacy_source: type, legacy_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid__redis(type, identifier, context, options \\ nil)
    def by_legacy_guid__redis(_type, identifier, _context, _options) when is_bitstring(identifier) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy_guid__ecto(type, identifier, context, options \\ nil)
    def by_legacy_guid__ecto(type, identifier, _context, _options) when is_bitstring(identifier) do
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^type,
                   where: r.legacy_guid_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.__erp__.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end



    def by_ref!(source, ref, context, options) do
      cond do
        ref = by_ref__mnesia(source, ref, context, options) -> ref
        ref = by_ref__redis(source,  ref, context, options) -> ref
        ref = by_ref__ecto(source,  ref, context, options) -> ref
        :else -> nil
      end
    end

    def by_ref__mnesia(source, ref, context, options) do
      case JetzySchema.Database.LegacyResolution.Table.match!([ref: ref,  legacy_source: source]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] ->  entity.legacy_guid_identifier || entity.legacy_identifier
        _ -> nil
      end
    end

    def by_ref__redis(source, ref, context, options), do: nil

    def by_ref__ecto(nil, _, _, _), do: nil
    def by_ref__ecto(_, nil, _, _), do: nil
    def by_ref__ecto(source, ref, context, options) do
      with {:ref, entity, identifier} <- ref do
  
        source = cond do
                   s = entity.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                   :else -> entity
                 end
                 
        query = from r in JetzySchema.PG.TanbitsResolution.Table,
                     where: r.source == ^source,
                     where: r.source_identifier == ^identifier,
                     select: r,
                     limit: 1
        case JetzySchema.PG.Repo.all(query) do
          [resolution| _] -> resolution.legacy_guid_identifier || resolution.legacy_identifier
          _ -> nil
        end
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy(type, identifier, context, options \\ nil)
    def by_legacy(type, %Decimal{} = identifier, context, options) , do: by_legacy(type, Decimal.to_integer(identifier), context, options)
    def by_legacy(type, identifier, context, options) when is_integer(identifier) do
      cond do
        ref = by_legacy__mnesia(type, identifier, context, options) -> ref
        ref = by_legacy__redis(type, identifier, context, options) -> ref
        ref = by_legacy__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy!(type, identifier, context, options \\ nil)
    def by_legacy!(type, %Decimal{} = identifier, context, options) , do: by_legacy!(type, Decimal.to_integer(identifier), context, options)
    def by_legacy!(type, identifier, context, options) when is_integer(identifier) do
      cond do
        ref = by_legacy__mnesia!(type, identifier, context, options) -> ref
        ref = by_legacy__redis(type, identifier, context, options) -> ref
        ref = by_legacy__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy__mnesia!(type, identifier, context, options \\ nil)
    def by_legacy__mnesia!(type, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match!([legacy_source: type, legacy_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy__mnesia(type, identifier, context, options \\ nil)
    def by_legacy__mnesia(type, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match([legacy_source: type, legacy_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%JetzySchema.Database.LegacyResolution.Table{} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy__redis(type, identifier, context, options \\ nil)
    def by_legacy__redis(_type, identifier, _context, _options) when is_integer(identifier) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy__ecto(type, identifier, context, options \\ nil)
    def by_legacy__ecto(type, identifier, _context, _options) when is_integer(identifier) do
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^type,
                   where: r.legacy_integer_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] ->
          resolution.source.__erp__.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy!(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy!(type, legacy_source, %Decimal{} = identifier, context, options) , do: by_type_and_legacy!(type, legacy_source, Decimal.to_integer(identifier), context, options)
    def by_type_and_legacy!(type, legacy_source, identifier, context, options) when is_integer(identifier) or is_bitstring(identifier) do
      cond do
        ref = by_type_and_legacy__mnesia!(type, legacy_source, identifier, context, options) -> ref
        ref = by_type_and_legacy__redis(type, legacy_source,  identifier, context, options) -> ref
        ref = by_type_and_legacy__ecto(type, legacy_source,  identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy(type, legacy_source, %Decimal{} = identifier, context, options) , do: by_type_and_legacy(type, legacy_source, Decimal.to_integer(identifier), context, options)
    def by_type_and_legacy(type, legacy_source, identifier, context, options) when is_integer(identifier) or is_bitstring(identifier) do
      cond do
        ref = by_type_and_legacy__mnesia(type, legacy_source, identifier, context, options) -> ref
        ref = by_type_and_legacy__redis(type, legacy_source,  identifier, context, options) -> ref
        ref = by_type_and_legacy__ecto(type, legacy_source,  identifier, context, options) -> ref
        :else -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy__mnesia!(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy__mnesia!(type, legacy_source, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match!([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    def by_type_and_legacy__mnesia!(type, legacy_source, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match!([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy__mnesia(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy__mnesia(type, legacy_source, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    def by_type_and_legacy__mnesia(type, legacy_source, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.LegacyResolution.Table.match([ref: {:ref, type, :_},  legacy_source: legacy_source, legacy_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.LegacyResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy__redis(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy__redis(_type, _legacy_source, identifier, _context, _options) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy__ecto(type, legacy_source, identifier, context, options \\ nil)
    def by_type_and_legacy__ecto(type, legacy_source, identifier, _context, _options) when is_integer(identifier) do
      source = cond do
                 s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                 :else -> type
               end
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.legacy_integer_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.__erp__.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end
    def by_type_and_legacy__ecto(type, legacy_source, identifier, _context, _options) when is_bitstring(identifier) do
      source = cond do
                 s = type.__persistence__(:schemas)[JetzySchema.PG.Repo] -> s.table
                 :else -> type
               end
      query = from r in JetzySchema.PG.LegacyResolution.Table,
                   where: r.legacy_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.legacy_guid_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.__erp__.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end

  end



end
