#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Credential.JetzyBCrypt do
  alias Noizu.AdvancedScaffolding.Schema.PersistenceLayer
  use Noizu.SimpleObject
  import Ecto.Query, only: [from: 2]
  @vsn 1.0
  @persistence_layer :ecto
  Noizu.SimpleObject.noizu_struct() do
    @required true
    @pii :level_0
    restricted_field :login

    @required true
    @pii :level_0
    restricted_field :password
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
    %JetzySchema.PG.User.Credential.JetzyBCrypt.Table{
      identifier: identifier,
      login: settings.login,
      password: settings.password,
      modified_on: %{modified_on| microsecond: {0, 6}}
    }
  end
  def __as_record__(layer, identifier, settings, context, options) do
    super(layer, identifier, settings, context, options)
  end


  def query_key(%__MODULE__{} = this), do: {:bcrypt, {this.login, this.password}}

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

  def by_setting__ecto(setting, _context, _options) do
    query = from c in JetzySchema.PG.User.Credential.JetzyBCrypt.Table,
                 where: c.login == ^setting.login,
                 where: c.password == ^setting.password,
                 select: c,
                 limit: 1
    case JetzySchema.PG.Repo.all(query) do
      [record|_] -> Jetzy.User.Credential.Entity.ref(record.identifier)
      _ -> nil
    end
  end

end

