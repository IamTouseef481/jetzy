#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.TanbitsResolution do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "tanbits-resolution"
  @persistence_layer {JetzySchema.Database, [cascade?: true, sync: true]}
  @persistence_layer {JetzySchema.PG.Repo, [cascade?: true, sync: true]}
  @universal_identifier false
  @universal_lookup false
  @auto_generate true
  @generate_reference_type :basic_ref
  @nmid_bare :node
  defmodule Entity do
    use Amnesia
    @nmid_index 297
    require Logger
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :ref

      public_field :tanbits_source
      public_field :tanbits_integer_identifier
      public_field :tanbits_guid_identifier
      public_field :tanbits_string_identifier
      public_field :tanbits_sub_identifier
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
          entity && __as_record_type__(layer, entity, context, options)
        _ -> Logger.error "#{__ENV__.file}:#{__ENV__.line} - Unexpected entity! - #{inspect ref}"
      end
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      case super(layer, entity, context, options) do
        record = %{__struct__: JetzySchema.PG.TanbitsResolution.Table} ->
          ref = Noizu.ERP.ref(entity.ref)
          sid = Noizu.EctoEntity.Protocol.ecto_identifier(ref)
          so = Noizu.EctoEntity.Protocol.source(ref)
          %JetzySchema.PG.TanbitsResolution.Table{record|
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
    def insert(ref, tanbits_source, tanbits_identifier, context, options \\ nil)
    def insert(_ref, _tanbits_source, nil, _context, _options), do: nil
    def insert(ref, tanbits_source, tanbits_identifier, context, options) when is_integer(tanbits_identifier) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_integer_identifier: tanbits_identifier,
      }
      |> create(context, options)
    end


    #---------------------------------------
    #
    #---------------------------------------
    def insert!(ref, tanbits_source, tanbits_identifier, context, options \\ nil)
    def insert!(_ref, _tanbits_source, nil, _context, _options), do: nil
    def insert!(ref, tanbits_source, tanbits_identifier, context, options) when is_integer(tanbits_identifier) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_integer_identifier: tanbits_identifier,
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
        JetzySchema.Database.TanbitsResolution.Table.match!([ref: ref,  tanbits_source: legacy_source])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
        query = from r in JetzySchema.PG.TanbitsResolution.Table,
                     where: r.tanbits_source == ^legacy_source,
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
        JetzySchema.Database.TanbitsResolution.Table.match!([ref: ref,  tanbits_source: legacy_source, tanbits_integer_identifier: legacy_identifier])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
        query = from r in JetzySchema.PG.TanbitsResolution.Table,
                     where: r.tanbits_source == ^legacy_source,
                     where: r.tanbits_integer_identifier == ^legacy_identifier,
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
        JetzySchema.Database.TanbitsResolution.Table.match!([ref: ref,  tanbits_source: legacy_source, tanbits_guid_identifier: legacy_identifier])
        |> Amnesia.Selection.values()
        |> Enum.map(fn(record) ->
          Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
        end)

        # purge redis

        # purge pg.
        source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
        query = from r in JetzySchema.PG.TanbitsResolution.Table,
                     where: r.tanbits_source == ^legacy_source,
                     where: r.tanbits_guid_identifier == ^legacy_identifier,
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
      JetzySchema.Database.TanbitsResolution.Table.match!([ref: {:ref, type, :_},  tanbits_source: legacy_source, tanbits_integer_identifier: legacy_identifier])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
      end)
      # purge redis

      # purge pg.
      source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.tanbits_integer_identifier == ^legacy_identifier,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
    end
    def remove!(type, legacy_source, legacy_identifier, context, options) when is_bitstring(legacy_identifier) do
      # purge mnesia
      JetzySchema.Database.TanbitsResolution.Table.match!([ref: {:ref, type, :_},  tanbits_source: legacy_source, tanbits_guid_identifier: legacy_identifier])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
      end)
      # purge redis

      # purge pg.
      source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.tanbits_guid_identifier == ^legacy_identifier,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
    end
    #---------------------------------------
    #
    #---------------------------------------
    def insert_guid(ref, tanbits_source, tanbits_identifier, context, options \\ nil)
    def insert_guid(_ref, _tanbits_source, nil, _context, _options), do: nil
    def insert_guid(ref, tanbits_source, tanbits_identifier, context, options) when is_bitstring(tanbits_identifier) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_guid_identifier: tanbits_identifier,
      } |> create(context, options)
    end

    #---------------------------------------
    #
    #---------------------------------------
    def insert_guid!(ref, tanbits_source, tanbits_identifier, context, options \\ nil)
    def insert_guid!(_ref, _tanbits_source, nil, _context, _options), do: nil
    def insert_guid!(ref, tanbits_source, tanbits_identifier, context, options) when is_bitstring(tanbits_identifier) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_guid_identifier: tanbits_identifier,
      } |> create!(context, options)
    end

    #---------------------------------------
    #
    #---------------------------------------
    def insert_identifier_and_guid(ref, tanbits_source, tanbits_identifier, tanbits_guid, context, options \\ nil)
    def insert_identifier_and_guid(ref, tanbits_source, tanbits_identifier, tanbits_guid, context, options) when is_integer(tanbits_identifier) or is_bitstring(tanbits_guid) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_integer_identifier: tanbits_identifier,
        tanbits_guid_identifier: tanbits_guid,
      } |> create(context, options)
    end
    def insert_identifier_and_guid(_ref, _tanbits_source, _tanbits_identifier, _tanbits_guid, _context, _options), do: nil

    #---------------------------------------
    #
    #---------------------------------------
    def insert_identifier_and_guid!(ref, tanbits_source, tanbits_identifier, tanbits_guid, context, options \\ nil)
    def insert_identifier_and_guid!(ref, tanbits_source, tanbits_identifier, tanbits_guid, context, options) when is_integer(tanbits_identifier) or is_bitstring(tanbits_guid) do
      %Jetzy.TanbitsResolution.Entity{
        ref: Noizu.ERP.ref(ref),
        tanbits_source: tanbits_source,
        tanbits_integer_identifier: tanbits_identifier,
        tanbits_guid_identifier: tanbits_guid,
      } |> create!(context, options)
    end
    def insert_identifier_and_guid!(_ref, _tanbits_source, _tanbits_identifier, _tanbits_guid, _context, _options), do: nil



    def remove_identifier_and_guid!(type, legacy_source, legacy_identifier, legacy_guid, context, options \\ nil)
    def remove_identifier_and_guid!(type, legacy_source, %Decimal{} = legacy_identifier, legacy_guid, context, options), do: remove_identifier_and_guid!(type, legacy_source, Decimal.to_integer(legacy_identifier), legacy_guid, context, options)
    def remove_identifier_and_guid!(type, legacy_source, legacy_identifier, legacy_guid, context, options) when is_integer(legacy_identifier) or is_bitstring(legacy_guid) do

      JetzySchema.Database.TanbitsResolution.Table.match!([
        ref: {:ref, type, :_},
        tanbits_source: legacy_source,
        tanbits_integer_identifier: legacy_identifier,
        tanbits_guid_identifier: legacy_guid,
      ])
      |> Amnesia.Selection.values()
      |> Enum.map(fn(record) ->
        Jetzy.TanbitsResolution.Repo.delete!(%Jetzy.TanbitsResolution.Entity{identifier: record.identifier}, context, options)
      end)


      # purge redis

      # purge pg.
      source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^legacy_source,
                   where: r.source == ^source,
                   where: r.tanbits_integer_identifier == ^legacy_identifier,
                   where: r.tanbits_guid_identifier == ^legacy_guid,
                   select: r
      JetzySchema.PG.Repo.delete_all(query)
    end
    def remove_identifier_and_guid!(_type, _legacy_source, _legacy_identifier, _legacy_guid, _context, _options), do: nil


    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid(type, identifier, context, options \\ nil)
    def by_tanbits_guid(type, identifier, context, options) when is_bitstring(identifier) do
      cond do
        ref = by_tanbits_guid__mnesia(type, identifier, context, options) -> ref
        ref = by_tanbits_guid__redis(type, identifier, context, options) -> ref
        ref = by_tanbits_guid__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid!(type, identifier, context, options \\ nil)
    def by_tanbits_guid!(type, identifier, context, options) when is_bitstring(identifier) do
      cond do
        ref = by_tanbits_guid__mnesia!(type, identifier, context, options) -> ref
        ref = by_tanbits_guid__redis(type, identifier, context, options) -> ref
        ref = by_tanbits_guid__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid__mnesia!(type, identifier, context, options \\ nil)
    def by_tanbits_guid__mnesia!(type, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match!([tanbits_source: type, tanbits_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid__mnesia(type, identifier, context, options \\ nil)
    def by_tanbits_guid__mnesia(type, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match([tanbits_source: type, tanbits_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid__redis(type, identifier, context, options \\ nil)
    def by_tanbits_guid__redis(_type, identifier, _context, _options) when is_bitstring(identifier) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits_guid__ecto(type, identifier, context, options \\ nil)
    def by_tanbits_guid__ecto(type, identifier, _context, _options) when is_bitstring(identifier) do
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^type,
                   where: r.tanbits_guid_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.__entity__().ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end




    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy(type, identifier, context, options \\ nil)
    def by_legacy(type, identifier, context, options) when is_integer(identifier) do
      cond do
        ref = by_tanbits__mnesia(type, identifier, context, options) -> ref
        ref = by_tanbits__redis(type, identifier, context, options) -> ref
        ref = by_tanbits__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_legacy!(type, identifier, context, options \\ nil)
    def by_legacy!(type, identifier, context, options) when is_integer(identifier) do
      cond do
        ref = by_tanbits__mnesia!(type, identifier, context, options) -> ref
        ref = by_tanbits__redis(type, identifier, context, options) -> ref
        ref = by_tanbits__ecto(type, identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits__mnesia!(type, identifier, context, options \\ nil)
    def by_tanbits__mnesia!(type, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match!([tanbits_source: type, tanbits_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits__mnesia(type, identifier, context, options \\ nil)
    def by_tanbits__mnesia(type, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match([tanbits_source: type, tanbits_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%JetzySchema.Database.TanbitsResolution.Table{} = entity|_] -> entity.ref
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits__redis(type, identifier, context, options \\ nil)
    def by_tanbits__redis(_type, identifier, _context, _options) when is_integer(identifier) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_tanbits__ecto(type, identifier, context, options \\ nil)
    def by_tanbits__ecto(type, identifier, _context, _options) when is_integer(identifier) do
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^type,
                   where: r.tanbits_integer_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] ->
          resolution.source.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy!(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_legacy!(type, tanbits_source, identifier, context, options) when is_integer(identifier) or is_bitstring(identifier) do
      cond do
        ref = by_type_and_tanbits__mnesia!(type, tanbits_source, identifier, context, options) -> ref
        ref = by_type_and_tanbits__redis(type, tanbits_source,  identifier, context, options) -> ref
        ref = by_type_and_tanbits__ecto(type, tanbits_source,  identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_legacy(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_legacy(type, tanbits_source, identifier, context, options) when is_integer(identifier) or is_bitstring(identifier) do
      cond do
        ref = by_type_and_tanbits__mnesia(type, tanbits_source, identifier, context, options) -> ref
        ref = by_type_and_tanbits__redis(type, tanbits_source,  identifier, context, options) -> ref
        ref = by_type_and_tanbits__ecto(type, tanbits_source,  identifier, context, options) -> ref
        :else -> nil
      end
    end


    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_tanbits__mnesia!(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_tanbits__mnesia!(type, tanbits_source, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match!([ref: {:ref, type, :_},  tanbits_source: tanbits_source, tanbits_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    def by_type_and_tanbits__mnesia!(type, tanbits_source, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match!([ref: {:ref, type, :_},  tanbits_source: tanbits_source, tanbits_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    
    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_tanbits__mnesia(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_tanbits__mnesia(type, tanbits_source, identifier, _context, _options) when is_integer(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match([ref: {:ref, type, :_},  tanbits_source: tanbits_source, tanbits_integer_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    def by_type_and_tanbits__mnesia(type, tanbits_source, identifier, _context, _options) when is_bitstring(identifier) do
      case JetzySchema.Database.TanbitsResolution.Table.match([ref: {:ref, type, :_},  tanbits_source: tanbits_source, tanbits_guid_identifier: identifier]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] -> entity.ref
        _ -> nil
      end
    end
    
    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_tanbits__redis(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_tanbits__redis(_type, _tanbits_source, identifier, _context, _options) when is_integer(identifier) or is_bitstring(identifier) do
      # todo
      nil
    end

    #---------------------------------------
    #
    #---------------------------------------
    def by_type_and_tanbits__ecto(type, tanbits_source, identifier, context, options \\ nil)
    def by_type_and_tanbits__ecto(type, tanbits_source, identifier, _context, _options) when is_integer(identifier) do
      source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^tanbits_source,
                   where: r.source == ^source,
                   where: r.tanbits_integer_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end
    def by_type_and_tanbits__ecto(type, tanbits_source, identifier, _context, _options) when is_bitstring(identifier) do
      source = type.__persistence__(:schemas)[JetzySchema.PG.Repo].table
      query = from r in JetzySchema.PG.TanbitsResolution.Table,
                   where: r.tanbits_source == ^tanbits_source,
                   where: r.source == ^source,
                   where: r.tanbits_guid_identifier == ^identifier,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution| _] -> resolution.source.ref({:ecto_identifier, resolution.source_identifier})
        _ -> nil
      end
    end
    
    #-------------------------------------------
    #
    #-------------------------------------------
    def tanbits_by_ref!(tanbits_source, ref, context, options) do
      cond do
        tanbits_ref = tanbits_by_ref__mnesia(tanbits_source, ref, context, options) -> tanbits_ref
        tanbits_ref = tanbits_by_ref__redis(tanbits_source,  ref, context, options) -> tanbits_ref
        tanbits_ref = tanbits_by_ref__ecto(tanbits_source,  ref, context, options) -> tanbits_ref
        :else -> nil
      end
    end

    def tanbits_by_ref__mnesia(tanbits_source, ref, context, options) do
      case JetzySchema.Database.TanbitsResolution.Table.match!([ref: ref,  tanbits_source: tanbits_source]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.TanbitsResolution.Table} = entity|_] ->  {:ref, tanbits_source, entity.tanbits_guid_identifier}
        _ -> nil
      end
    end

    def tanbits_by_ref__redis(tanbits_source, ref, context, options), do: nil

    def tanbits_by_ref__ecto(nil, _, _, _), do: nil
    def tanbits_by_ref__ecto(_, nil, _, _), do: nil
    def tanbits_by_ref__ecto(tanbits_source, ref, _context, _options) do
      with {:ref, entity, _} <- ref,
           source = entity.source(Data.Repo) do
           identifier = Noizu.EctoEntity.Protocol.ecto_identifier(ref)
           # TANBITS| Jetzy.User.Location.History.Entity, nil, Data.Schema.UserGeoLocationLog  {:ref, Jetzy.User.Location.History.Entity, 13301343}
           # Logger.info "TANBITS| #{inspect source}, #{inspect identifier}, #{inspect tanbits_source}  #{inspect ref}"
        query = from r in JetzySchema.PG.TanbitsResolution.Table,
                     where: r.tanbits_source == ^tanbits_source,
                     where: r.source == ^source,
                     where: r.source_identifier == ^identifier,
                     select: r,
                     limit: 1
        case JetzySchema.PG.Repo.all(query) do
          [resolution| _] -> {:ref, tanbits_source, resolution.tanbits_guid_identifier}
          _ -> nil
        end
      end
    end




  end # end repo



end
