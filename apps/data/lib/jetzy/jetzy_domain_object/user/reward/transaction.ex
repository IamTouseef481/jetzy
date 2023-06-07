#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Reward.Transaction do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "usr-rwd-txn"
  @persistence_layer {:ecto, [cascade?: true, sync: true, fallback?: true, cascade_block?: true]}
  @persistence_layer {Data.Repo, Data.Schema.UserOfferTransaction, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  # @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 319
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :user, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :source, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :transaction_type
      public_field :transaction_status
      public_field :points
      public_field :note, nil, Jetzy.VersionedString.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    
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
    import Ecto.Query, only: [from: 2]
    require Logger
    Noizu.DomainObject.noizu_repo do
    end
    
    
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
    # layer_create
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      {source, legacy_id} = case entity.meta[:source] do
                              {source, id} -> {source, id}
                              _ -> {nil, nil}
                            end
      
      cond do
        entity.transaction_type == :redeem || source == JetzySchema.MSSQL.User.Offer.Transaction.Table ->
          user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options)
                 |> Noizu.ERP.id()
          offer = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RewardOffer, Noizu.ERP.ref(entity.source), context, options)
                  |> Noizu.ERP.id()
          {is_cancelled, is_completed} = case entity.transaction_status do
                                           :pending -> {false, false}
                                           :completed -> {false, true}
                                           :cancelled -> {true, false}
                                         end
          description = Noizu.ERP.entity!(entity.note)
          remarks = description && description.body && description.body.markdown
          
          record = %Data.Schema.UserOfferTransaction{
            balance_point: (entity.__transient__[:balance] || 0) * 1.0,
            point: -entity.points * 1.0,
            is_canceled: is_cancelled,
            is_completed: is_completed,
            offer_id: offer,
            remarks: remarks,
            user_id: user,
            deleted_at: entity.time_stamp.deleted_on,
            inserted_at: entity.time_stamp.created_on,
            updated_at: entity.time_stamp.modified_on,
          }
          with {:ok, record} <- Data.Repo.upsert(record) do
            Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserOfferTransaction, record.id, context, options)
          else
            error -> Logger.warn "#{__MODULE__} Exception during import  #{inspect error, pretty: true, limit: :infinity},\n #{inspect record, pretty: true, limit: :infinity}"
          end
        entity.transaction_type == :event || source == JetzySchema.MSSQL.User.Reward.Transaction.Table ->
          user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options)
                 |> Noizu.ERP.id()
          reward = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RewardManager, Noizu.ERP.ref(entity.source), context, options)
                   |> Noizu.ERP.id() || "00000000-0000-0000-0000-000000000000"
          {is_cancelled, is_completed} = case entity.transaction_status do
                                           :pending -> {false, false}
                                           :completed -> {false, true}
                                           :cancelled -> {true, false}
                                         end
          description = Noizu.ERP.entity!(entity.note)
          remarks = description && description.body && description.body.markdown
          
          record = %Data.Schema.UserRewardTransaction{
            balance_point: (entity.__transient__[:balance] || 0) * 1.0,
            point: entity.points * 1.0,
            is_canceled: is_cancelled,
            is_completed: is_completed,
            reward_id: reward,
            remarks: remarks,
            user_id: user,
            deleted_at: entity.time_stamp.deleted_on,
            inserted_at: entity.time_stamp.created_on,
            updated_at: entity.time_stamp.modified_on,
          }
          with {:ok, record} <- Data.Repo.upsert(record) do
            Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserRewardTransaction, record.id, context, options)
          else
            error -> Logger.warn "#{__MODULE__} Exception during import  #{inspect error, pretty: true, limit: :infinity},\n #{inspect record, pretty: true, limit: :infinity}"
          end
        :else -> Logger.error("#{__MODULE__} #{inspect Noizu.ERP.ref(entity)} - unable to resolve insert type")
      end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end
    
    
    
    def import!(%JetzySchema.MSSQL.User.Offer.Transaction.Table{} = record, context, options) do
      Logger.info("Importing #{record.__struct__}@#{record.id}")
      existing = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Offer.Transaction.Table, record.id, context, options)
      existing = case existing do
                   {:ref, _, id} ->
                     if JetzySchema.PG.Repo.get(JetzySchema.PG.User.Reward.Transaction.Table, id) do
                       existing
                     else
                       query = from l in JetzySchema.PG.LegacyResolution.Table, where: l.source_identifier == ^id, select: [l.identifier]
                       JetzySchema.PG.Repo.delete_all(query)
            
                       JetzySchema.Database.LegacyResolution.Table.match!(ref: {:ref, Jetzy.User.Reward.Transaction.Entity, id})
                       |> Amnesia.Selection.values
                       |> Enum.map(&(JetzySchema.Database.LegacyResolution.Table.delete!(&1.identifier)))
                       nil
                     end
                   other -> other
                 end
      
      cond do
        existing ->
          Logger.info("Skipping #{record.__struct__}@#{record.id}")
          {:error, {:exists, existing}}
        :else ->
          Logger.info("Importing #{record.__struct__}@#{record.id}")
          user = Jetzy.User.Repo.by_guid!(record.user_id, context, options) |> Noizu.ERP.ref
          offer = Jetzy.Offer.Repo.by_legacy!(record.offer_id, context, options)
          transaction_status = cond do
                                 record.is_cancelled -> :cancelled
                                 record.is_completed -> :completed
                                 :else -> :pending
                               end
          transaction_type = cond do
                               offer == nil -> :admin
                               :else -> :redeem
                             end
          
          points = Decimal.to_integer(record.point)
          balance = Decimal.to_integer(record.balance_point)
          
          imported = %Jetzy.User.Reward.Transaction.Entity{
                       user: user,
                       source: offer,
                       transaction_type: transaction_type,
                       transaction_status: transaction_status,
                       points: -points,
                       note: %{title: "note", body: record.remarks || ""},
                       time_stamp: JetzySchema.MSSQL.User.Offer.Transaction.Table.time_stamp(record, context, options),
                       __transient__: [balance: balance],
                       meta: [source: {record.__struct__, record.id}]
                     } |> Jetzy.User.Reward.Transaction.Repo.create!(context, options)
          imported.identifier && Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(imported), JetzySchema.MSSQL.User.Offer.Transaction.Table, record.id, context, options)
          {:imported, imported}
      end
    end
    
    
    def import!(%JetzySchema.MSSQL.User.Reward.Transaction.Table{} = record, context, options) do
      existing = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Reward.Transaction.Table, record.id, context, options)
      existing = case existing do
                   {:ref, _, id} ->
                     if JetzySchema.PG.Repo.get(JetzySchema.PG.User.Reward.Transaction.Table, id) do
                       existing
                     else
                       query = from l in JetzySchema.PG.LegacyResolution.Table, where: l.source_identifier == ^id, select: [l.identifier]
                       JetzySchema.PG.Repo.delete_all(query)
            
                       JetzySchema.Database.LegacyResolution.Table.match!(ref: {:ref, Jetzy.User.Reward.Transaction.Entity, id})
                       |> Amnesia.Selection.values
                       |> Enum.map(&(JetzySchema.Database.LegacyResolution.Table.delete!(&1.identifier)))
                       nil
                     end
                   other -> other
                 end
      
      cond do
        existing ->
          Logger.info("Skipping #{record.__struct__}@#{record.id}")
          {:error, {:exists, existing}}
        :else ->
          Logger.info("Importing #{record.__struct__}@#{record.id}")
          user = Jetzy.User.Repo.by_guid!(record.user_id, context, options) |> Noizu.ERP.ref
          reward = Jetzy.Reward.Event.Repo.by_legacy!(record.reward_id, context, options)
          transaction_status = cond do
                                 record.is_cancelled -> :cancelled
                                 record.is_completed -> :completed
                                 :else -> :pending
                               end
          transaction_type = cond do
                               reward == nil -> :admin
                               :else -> :event
                             end
          
          points = Decimal.to_integer(record.point)
          balance = Decimal.to_integer(record.balance_point)
          
          imported = %Jetzy.User.Reward.Transaction.Entity{
                       user: user,
                       source: reward,
                       transaction_type: transaction_type,
                       transaction_status: transaction_status,
                       points: points,
                       note: %{title: "note", body: record.remarks || ""},
                       time_stamp: JetzySchema.MSSQL.User.Reward.Transaction.Table.time_stamp(record, context, options),
                       __transient__: [balance: balance],
                       meta: [source: {record.__struct__, record.id}]
                     } |> Jetzy.User.Reward.Transaction.Repo.create!(context, options)
          imported.identifier && Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(imported), JetzySchema.MSSQL.User.Reward.Transaction.Table, record.id, context, options)
          {:imported, imported}
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
