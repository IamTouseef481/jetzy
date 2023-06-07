#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Reward.Tier do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "reward-tier"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {Data.Repo, Data.Schema.RewardTier, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 309
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :tier_start

      @index true
      public_field :tier_end

      @index true
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :details, nil, Jetzy.CMS.Article.Post.TypeHandler

      @index true
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
      {name, description} = Jetzy.VersionedString.Entity.entity!(entity.description)
                            |> case do
                                 %{title: title, body: body} -> {title && title.markdown, body && body.markdown}
                                 _ -> {nil, nil}
                               end
      record = %Data.Schema.RewardTier{
        tier_name: name,
        description: description,
        deleted_at: entity.time_stamp.deleted_on,
        address: nil,
        start_point: entity.tier_start * 1.0,
        end_point: entity.tier_end * 1.0,
        is_deleted: entity.time_stamp.deleted_on && true || false,
      }
      {:ok, record} = Data.Repo.upsert(record)

      # Insert Guid for lookup.
      Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.RewardTier, record.id, context, options)
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    def by_legacy!(id, context, options) do
      case Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Reward.Tier.Table, id, context, options) do
        ref = {:ref, _, _} -> ref
        _ -> import!(id, context, options)
      end
    end

    def import!(identifier, context, options) when is_integer(identifier) do
      record = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Reward.Tier.Table, identifier)
      record && import!(record, context, options)
    end
    def import!(%JetzySchema.MSSQL.Reward.Tier.Table{} = record, context, options) do
      cond do
        existing = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Reward.Tier.Table, record.id, context, options) -> existing
        :else ->
        tier = %Jetzy.Reward.Tier.Entity{
          description: %{title: record.tier_name, body: record.description},
          tier_start: record.start_point,
          tier_end: record.end_point,
          time_stamp: JetzySchema.MSSQL.Reward.Tier.Table.time_stamp(record, context, options)
        } |> Jetzy.Reward.Tier.Repo.create!(context, options)
        Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(tier), JetzySchema.MSSQL.Reward.Tier.Table, record.id, context, options)
        tier
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
