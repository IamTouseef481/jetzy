#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Interest do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-interest"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  @persistence_layer {Data.Repo, Data.Schema.UserInterest, [cascade?: true, sync: true, fallback?: false, cascade_block?: true]}
  defmodule Entity do
    @nmid_index 121
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid  # Same as user
      @ref Jetzy.User.Entity
      public_field :user #, nil, JetzySchema.Types.User.Reference
      @ref Jetzy.Interest.Entity
      public_field :interest, nil, Jetzy.Interest.TypeHandler
      public_field :visibility
      # public_field :active
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
    require Logger
    Noizu.DomainObject.noizu_repo do
    end



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
      user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options)
      interest = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.Interest, Noizu.ERP.ref(entity.interest), context, options)
      is_active = if entity.time_stamp.deleted_on, do: false, else: true
      record = %{
        deleted_at: entity.time_stamp.deleted_on || nil,
        is_active: is_active,
        is_admin: false,
        user_id: Noizu.ERP.id(user),
        interest_id: Noizu.ERP.id(interest),
      }
      {:ok, insert} = Data.Context.create(Data.Schema.UserInterest, record)
      Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserInterest, insert.id, context, options)
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    def layer_update(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_update!(layer, entity, context, options)
    end
    def layer_update(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_update
    #----------------------------
    def layer_update!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options)
      interest = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.Interest, Noizu.ERP.ref(entity.interest), context, options)
      existing = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserInterest, Noizu.ERP.ref(entity), context, options) |> Noizu.ERP.entity!()
      if existing do
        record = %{
          identifier: Noizu.ERP.id(existing),
          #deleted_at: entity.time_stamp.deleted_on || nil,
          #is_active: entity.time_stamp.deleted_on && true || false,
          #is_admin: false,
          user_id: Noizu.ERP.id(user),
          interest_id: Noizu.ERP.id(interest),
        }
        Data.Repo.update(Data.Schema.UserInterest.changeset(existing, record))
      else
        record = %{
          deleted_at: entity.time_stamp.deleted_on || nil,
          is_active: entity.time_stamp.deleted_on && true || false,
          is_admin: false,
          user_id: Noizu.ERP.id(user),
          interest_id: Noizu.ERP.id(interest),
        }
        {:ok, insert} = Data.Context.create(Data.Schema.UserInterest, record)
        Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserInterest, insert.id, context, options)
      end
      entity
    end
    def layer_update!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #------------------------------------
    # import!
    #------------------------------------
    def import!(guid, context, options \\ nil)
    def import!(_guid, context, _options) when not is_system_caller(context), do: {:error, :permission_denied}
    def import!(guid, context, options) when is_integer(guid) do
      cond do
        record = Data.Schema.UserInterest.by_legacy!(guid, context, options) -> import!(record, context, options)
        record = JetzySchema.MSSQL.User.Interest.Table.by_legacy!(guid, context, options) -> import!(record, context, options)
        :else -> {:error, :not_found}
      end
    end
    def import!(%Decimal{} = guid, context, options) do
      import!(Decimal.to_integer(guid), context, options)
    end
    def import!(%{__struct__: JetzySchema.MSSQL.User.Interest.Table} = record, context, options) do
      # Load Interest
      now = options[:current_time] || DateTime.utc_now()
      interest = Jetzy.Interest.Repo.by_legacy!(record.interest_id, context, options)
      user = Jetzy.User.Repo.by_guid!(record.user_id, context, options)
      {:imported, %Jetzy.User.Interest.Entity{
        user: user,
        interest: Noizu.ERP.ref(interest),
        visibility: :public, # depends on interest
        time_stamp: Noizu.DomainObject.TimeStamp.Second.import(record.created_on, record.modified_on, !record.is_active && (record.modified_on || now) || nil),
      } |> Jetzy.User.Interest.Repo.create!(context)
      }
    end
    def import!(%{__struct__: Data.Schema.UserInterest} = _record, _context, _options) do
      {:error, :nyi}
    end
    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
    end

    #------------------------------------
    # by_legacy
    #------------------------------------
    def by_legacy(guid, context, options \\ nil), do: by_legacy!(guid, context, options)

    #------------------------------------
    # by_guid!
    #------------------------------------
    def by_legacy!(guid, context, options \\ nil)
    def by_legacy!(nil, _context, _options), do: nil
    def by_legacy!(guid, context, options) do
      cond do
        entity_ref = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Interest.Table, guid, context, options) ->
          entity_ref
        options[:import] == false -> nil
        :else ->
          case Jetzy.User.Interest.Repo.import!(guid, context, options) do
            {:imported, entity} ->
              Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.User.Interest.Table, guid, context, options)
              Noizu.ERP.ref(entity)
            {:refreshed, entity} ->
              Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.User.Interest.Table, guid, context, options)
              Noizu.ERP.ref(entity)
            v ->
              Logger.info  """
              [DEBUG] #{__ENV__.line} - #{inspect v}
              """
              nil
          end
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
