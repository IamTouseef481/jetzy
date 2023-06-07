#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Notification.Setting do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-notification-setting"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 337
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :user, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :notification_type
      public_field :push_delivery_type
      public_field :sms_delivery_type
      public_field :email_delivery_type
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
      user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options)
             |> Noizu.ERP.id()
      notification_type = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.NotificationType, Jetzy.User.Notification.Type.Entity.ref(entity.notification_type), context, options)
                          |> Noizu.ERP.id()

      is_send_mail = case entity.email_delivery_type do
                      :send -> true
                      :digest -> true
                      _ -> false
                     end
      is_send_notification = case entity.push_delivery_type do
                       :send -> true
                       :digest -> true
                       _ -> false
                     end

      record = %Data.Schema.NotificationSetting{
        is_send_mail: is_send_mail,
        is_send_notification: is_send_notification,
        user: user,
        notification_type: notification_type,
        inserted_at: entity.time_stamp.created_on,
        updated_at: entity.time_stamp.modified_on,
        deleted_at: entity.time_stamp.deleted_on,
      }
      with {:ok, record} <- Data.Repo.upsert(record) do
        # Insert Guid for lookup.
        Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.NotificationSetting, record.id, context, options)
      else
        error ->
          Logger.error "#{__MODULE__} - import error #{inspect error}\n #{inspect record}}"
      end

      
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    def import!(%JetzySchema.MSSQL.Notification.Setting.Table{} = record, context, options) do
      existing = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Notification.Setting.Table, record.id, context, options)
      cond do
        existing -> {:error, {:exists, existing}}
        :else ->
          user = Jetzy.User.Repo.by_guid!(record.user, context, options) |> Noizu.ERP.ref()
          entity = %Jetzy.User.Notification.Setting.Entity{
            user: user,
            notification_type: Jetzy.User.Notification.Type.Repo.legacy_enum_to_atom(record.notification_type),
            push_delivery_type: record.send_notification  && :send || :disabled,
            email_delivery_type: record.send_mail && :send || :disabled,
            sms_delivery_type: :disabled,
            time_stamp: JetzySchema.MSSQL.Notification.Setting.Table.time_stamp(record, context, options),
            meta: [source: {record.__struct__, record.id}]
          } |> Jetzy.User.Notification.Setting.Repo.create!(context, options)
          Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Notification.Setting.Table, record.id, context, options)
          {:imported, entity}
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
