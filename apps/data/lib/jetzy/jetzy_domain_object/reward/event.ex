#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Reward.Event do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "reward-event"
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {Data.Repo, Data.Schema.RewardManager, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @persistence_layer {JetzySchema.MSSQL.Repo,  [sync: false, fallback?: false]}
  # @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 334
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :activity_type
      public_field :points
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    #----------------------------
    # existing
    #----------------------------
    def existing(guid, context, options) do
      cond do
        options[:existing] == false -> nil
        options[:existing] -> options[:existing]
        e = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Manager.Table, guid, context, options) -> entity(e)
        :else -> nil
      end
    end
    
    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Reward.Manager.Table} = record, context, options) do
      existing = existing(record.id, context, options)
      
      activity_type = cond do
                        record.activity_type == 0 -> :sign_up
                        :else -> Jetzy.Offer.Activity.Type.Enum.Ecto.EnumType.enum_to_atom(record.activity_type)
                      end
      description = existing && existing.description || %{title: record.activity, body: record.activity}
      meta = (existing && existing.meta || [])
             |> put_in([:guid], record.id)
             |> put_in([:source], :legacy)

      %Jetzy.Reward.Event.Entity{(existing || %Jetzy.Reward.Event.Entity{})|
                 description: description,
                 points: record.winning_point,
                 activity_type: activity_type,
                 time_stamp: JetzySchema.MSSQL.Reward.Manager.Table.time_stamp(record, context, options),
                 __transient__: [partials: true, record: record, existing: existing],
                 meta: meta
               }
    end
    def __from_record__(layer, record, context, options), do: super(layer, record, context, options)

    
    
    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end

  defmodule Repo do
    require Logger
    Noizu.DomainObject.noizu_repo do
    end

    #----------------------------
    # insert_lookup
    #----------------------------
    def insert_lookup(entity, context, options) do
      if (entity.__transient__[:record]) do
        le = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Manager.Table, entity.__transient__[:record].id, context, options)
        cond do
          le == nil -> Jetzy.LegacyResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Reward.Manager.Table, entity.__transient__[:record].id, context, options)
          Noizu.ERP.entity!(le) -> :skip
          :else ->
            # this is unexpected.
            Logger.warn("#{__MODULE__}.create invalid by_legacy ref #{inspect le} | #{inspect entity.__transient__[:record].id}")
        end
      end
    end

    #----------------------------
    # layer_create_callback
    #----------------------------
    def layer_create_callback(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      insert_lookup(entity, context, options)
      super(layer, entity, context, options)
    end
    def layer_create_callback(layer, entity, context, options), do: super(layer, entity, context, options)

    def layer_create_callback!(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      insert_lookup(entity, context, options)
      super(layer, entity, context, options)
    end
    def layer_create_callback!(layer, entity, context, options), do: super(layer, entity, context, options)



    #----------------------------
    # layer_create
    #----------------------------
    def layer_create(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_create!(layer, entity, context, options)
    end
    def layer_create(layer, entity, context, options) do
      super(layer, entity, context, options)
    end
    
    #----------------------------
    # layer_create!
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      cond do
        tanbits_ref = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RewardManager, Noizu.ERP.ref(entity), context, options) ->
          cond do
            existing = Noizu.ERP.entity!(tanbits_ref) -> {:ok, existing}
            :else -> {:error, {:lookup_table_corruption, {Noizu.ERP.ref(entity), entity.__transient__[:legacy], tanbits_ref}}}
          end
        existing = entity.meta[:guid] && Data.Repo.get(Data.Schema.RewardManager, entity.meta[:guid]) ->
          case existing do
            %Data.Schema.RewardManager{} ->
              Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.RewardManager, existing.id, context, options)
              {:ok, existing}
            :else -> {:error, {:fetch_by_guid_error, {Noizu.ERP.ref(entity), entity.__transient__[:legacy], existing}}}
          end
        :else -> {:ok, nil}
      end
      |> case do
           {:ok, existing} ->
             activity_type = Jetzy.Offer.Activity.Type.Enum.Ecto.EnumType.atom_to_enum(entity.activity_type)
             activity = case Noizu.ERP.entity!(entity.description) do
                          %{body: %{markdown: v}} -> v
                          %{body: v} -> v || ""
                          _ -> ""
                        end
             update = %Data.Schema.RewardManager{(existing || %Data.Schema.RewardManager{})|
                        id: existing && existing.id || entity.meta[:guid],
                        activity: activity,
                        activity_type: activity_type,
                        is_deleted: entity.time_stamp.deleted_on && true || false,
                        winning_point: entity.points * 1.0,
                        inserted_at: entity.time_stamp.created_on,
                        updated_at: entity.time_stamp.modified_on,
                        deleted_at: entity.time_stamp.deleted_on
                      }
            cond do
               existing ->
                 with {:ok, _} <- Data.Repo.update(Data.Schema.RewardManager.changeset(update)) do
                   :ok
                 else
                   pg -> Logger.warn("#{__MODULE__} Update Error: #{inspect pg, pretty: true, limit: :infinity, printable_limit: :infinity}")
                 end
               :else ->
                 with {:ok, updated} <- Data.Repo.upsert(update) do
                   Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.RewardManager, updated.id, context, options)
                 else
                   pg -> Logger.warn("#{__MODULE__} Upsert Error: #{inspect pg, pretty: true, limit: :infinity, printable_limit: :infinity}")
                 end
             end
           error ->
             Logger.warn("#{__MODULE__} layer_create Error: #{inspect error, pretty: true, limit: :infinity, printable_limit: :infinity}")
         end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end
    
    #----------------------------
    #
    #----------------------------
    def by_legacy!(identifier, context, options) do
      cond do
        existing = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Manager.Table, identifier, context, options) -> existing
        :else -> import!(identifier, context, options)
      end
    end

    #----------------------------
    #
    #----------------------------
    def import!(identifier, context, options) when is_bitstring(identifier) do
      record = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Reward.Manager.Table, identifier)
      record && import!(record, context, options)
    end
    def import!(%JetzySchema.MSSQL.Reward.Manager.Table{} = record, context, options) do
      existing_ref = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Manager.Table, record.id, context, options)
      existing = existing_ref && (get!(Noizu.ERP.id(existing_ref), context, []) || throw "Unable to continue, missing record #{inspect existing_ref}")
      options_b = put_in(options || [], [:existing], existing || false)
      
      cond do
        existing -> {:error, {:refresh, existing_ref}}
        entity = Jetzy.Reward.Event.Entity.__from_record__(Jetzy.Reward.Event.Repo.__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          imported_entity = create!(entity, context, options)
          {:imported, imported_entity}
        :else -> {:error, :unsupported}
      end
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end
end
