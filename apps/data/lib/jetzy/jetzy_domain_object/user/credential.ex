#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Credential do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-credential"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @persistence_layer {JetzySchema.MSSQL.Repo,  [cascade?: false, sync: false]}
  @auto_generate true
  defmodule Entity do
    @nmid_index 125
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      @ref Jetzy.User.Entity
      @pii :level_0
      @required true
      restricted_field :user

      @enum Jetzy.Origin.Source
      @pii :level_0
      @required true
      restricted_field :origin

      @enum Jetzy.Status
      @pii :level_0
      @required true
      restricted_field :status

      @enum Jetzy.Credential.Type
      @pii :level_0
      @required true
      restricted_field :credential_type

      @enum Jetzy.Credential.Provider
      @pii :level_0
      @required true
      restricted_field :credential_provider

      @pii :level_0
      @required true
      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler

      @struct Jetzy.User.Credential.JetzyBCrypt
      @struct Jetzy.User.Credential.Firebase
      @struct [Jetzy.User.Credential.JetzyLegacy, Jetzy.User.Credential.JetzyLegacySession]
      @pii :level_0
      @required true
      restricted_field :settings, nil, Jetzy.Credential.Settings.TypeHandler
    end


    def __as_record__(layer, entity, context, options \\ nil)
    def __as_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.User.Credential.Table} = layer, entity, context, options) do
      credential_record = super(layer, entity, context, options)
      credential_settings = entity.settings.__struct__.__as_record__(layer, entity.identifier, entity.settings, context, options)
      [credential_record, credential_settings]
    end
    def __as_record__(layer, entity, context, options), do: super(layer, entity, context, options)

    def __as_record__!(layer, entity, context, options \\ nil)
    def __as_record__!(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.User.Credential.Table} = layer, entity, context, options) do
      credential_record = super(layer, entity, context, options)
      credential_settings = entity.settings.__struct__.__as_record__!(layer, entity.identifier, entity.settings, context, options)
      [credential_record, credential_settings]
    end
    def __as_record__!(layer, entity, context, options), do: super(layer, entity, context, options)

  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end

    def by_setting!(setting, context, options \\ nil) do
      cond do
        ref = by_setting__mnesia(setting, context, options) -> ref
        ref = by_setting__ecto(setting, context, options) -> ref
        :else -> nil
      end
    end

    def by_setting__mnesia(setting, _context, _options \\ nil) do
      key = setting.__struct__.query_key(setting)
      case JetzySchema.Database.User.Credential.Table.match!([query_key: key]) |> Amnesia.Selection.values() do
        [record|_] -> Noizu.ERP.ref(record.entity)
        _ -> nil
      end
    end

    def by_setting__ecto(setting, context, options \\ nil) do
      setting.__struct__.by_setting!(setting, context, options)
    end













    def add_legacy_session_credential(user, record = %{__struct__: JetzySchema.MSSQL.User.Session.Table}, context, options) do
      now = options[:current_time] || DateTime.utc_now()
      %Jetzy.User.Credential.Entity{
        user: Jetzy.User.Entity.ref(user),
        origin: :legacy,
        status: record.is_active && :active || :inactive,
        credential_type: :api_legacy_session,
        credential_provider: :api,
        settings: %Jetzy.User.Credential.JetzyLegacySession{
          guid: String.upcase(record.user_id),
          session: record.session_id,
          # TODO device
          session_active: true,
          recheck_after: Timex.shift(now, hours: 1),
        },
        time_stamp: %Noizu.DomainObject.TimeStamp.Second{created_on: now, modified_on: now},
      } |> Jetzy.User.Credential.Repo.create!(Noizu.ElixirCore.CallingContext.system(context), options)
    end
  end

end
