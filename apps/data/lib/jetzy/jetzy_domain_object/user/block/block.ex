#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Block do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-block"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {Data.Repo, Data.Schema.UserBlock, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 323
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :user
      public_field :block

      public_field :status
      public_field :blocked_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :reason, nil, Jetzy.VersionedString.TypeHandler

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
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      with {:ok, user} <- Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options) |> Noizu.ERP.id_ok(),
           {:ok, relation} <- Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.block), context, options)  |> Noizu.ERP.id_ok() do
        record = %{
          user_from_id: user,
          user_to_id: relation,
          is_blocked: entity.status == :active && true || false,
          deleted_at: entity.time_stamp.deleted_on || nil,
          inserted_at: entity.time_stamp.created_on,
          updated_at: entity.time_stamp.modified_on,
        }
        with {:ok, insert} <- Data.Context.create(Data.Schema.UserBlock, record) do
          Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserBlock, insert.id, context, options)
        else
          error ->
            Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
            error
        end
      else
        error ->
          Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
          error
      end
      entity
    end
    def layer_create!(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      entity = super(layer, entity, context, options)
      if (entity.meta[:legacy_identifier]) do
        Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.User.Friend.Table, entity.meta[:legacy_identifier], context, options)
      end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end



    def by_user(user_a, user_b, context, options) do
      JetzySchema.Database.User.Block.Table.match!([user: user_a, block: user_b])
      |> Amnesia.Selection.values()
      |> case do
        [h|_] -> h.entity
        _ -> nil
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
