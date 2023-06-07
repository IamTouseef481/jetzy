#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Credential.JetzyLegacySession do
  alias Noizu.AdvancedScaffolding.Schema.PersistenceLayer
  import Ecto.Query, only: [from: 2]
  use Noizu.SimpleObject
  @vsn 1.0
  @persistence_layer :ecto
  Noizu.SimpleObject.noizu_struct() do
    @required true
    @pii :level_0
    restricted_field :guid

    @required true
    @pii :level_0
    restricted_field :session

    @required true
    @pii :level_0
    restricted_field :session_active

    @required true
    @pii :level_0
    restricted_field :recheck_after, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
  end

  def ref(_), do: nil

  #---------------------------
  # __as_record__!
  #---------------------------
  def __as_record__!(layer, identifier, settings, context, options) do
    __as_record__(layer, identifier, settings, context, options)
  end

  #---------------------------
  # __as_record__
  #---------------------------
  def __as_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = _layer, identifier, settings, _context, options) do
    modified_on = options[:current_time] || DateTime.utc_now()
    %JetzySchema.PG.User.Credential.JetzyLegacySession.Table{
      identifier: identifier,
      guid: settings.guid,
      session: settings.session,
      session_active: settings.session_active,
      recheck_after: settings.recheck_after && %{settings.recheck_after| microsecond: {0, 6}},
      modified_on: %{modified_on| microsecond: {0, 6}}
    }
  end
  def __as_record__(layer, identifier, settings, context, options) do
    super(layer, identifier, settings, context, options)
  end

  def query_key(%__MODULE__{} = this), do: {:api_legacy_session, {this.guid, this.session}}

  def by_setting!(setting, context, options \\ nil) do
    cond do
      ref = by_setting__mnesia(setting, context, options) -> ref
      ref = by_setting__ecto(setting, context, options) -> ref
      :else -> nil
    end
  end

  def by_setting__mnesia(setting, _context, _options) do
    key = query_key(setting)
    case JetzySchema.Database.User.Credential.Table.match!([query_key: key]) |> Amnesia.Selection.values() do
      [record|_] -> Noizu.ERP.ref(record.entity)
      _ -> nil
    end
  end

  def by_setting__ecto(setting, _context, options) do
    session = setting.session
    guid = setting.guid
    limit = options[:session][:query_limit] || 1
    query = cond do
              session && session != :_  && guid && guid != :_ ->
                from c in JetzySchema.PG.User.Credential.JetzyLegacySession.Table,
                     where: c.guid == ^setting.guid,
                     where: c.session == ^setting.session,
                     select: c,
                     limit: ^limit

              guid && guid != :_ ->
                from c in JetzySchema.PG.User.Credential.JetzyLegacySession.Table,
                     where: c.guid == ^setting.guid,
                     select: c,
                     limit: ^limit

              session && session != :_ ->
                from c in JetzySchema.PG.User.Credential.JetzyLegacySession.Table,
                     where: c.session == ^setting.session,
                     select: c,
                     limit: ^limit
              :else -> nil
            end

    case query && JetzySchema.PG.Repo.all(query) do
      [record|_] -> Jetzy.User.Credential.Entity.ref(record.identifier)
      _ -> nil
    end
  end
end
