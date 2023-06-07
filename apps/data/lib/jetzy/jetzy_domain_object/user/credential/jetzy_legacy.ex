#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Credential.JetzyLegacy do
  alias Noizu.AdvancedScaffolding.Schema.PersistenceLayer
  import Ecto.Query, only: [from: 2]
  #===----
  # Legacy MSSQL Password Encryption
  #===----
  #@legacy_password_hash Application.get_env(:api, :legacy_password_hash)
  #@legacy_password_salt Application.get_env(:api, :legacy_password_salt)
  #@legacy_vi_key Application.get_env(:api, :legacy_vi_key)
  #@aes_block_size 16


  use Noizu.SimpleObject
  @vsn 1.0
  @persistence_layer :ecto
  Noizu.SimpleObject.noizu_struct() do
    @required true
    @pii :level_0
    restricted_field :login_name

    @required true
    @pii :level_0
    restricted_field :guid

    @required true
    @pii :level_0
    restricted_field :password_hash
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
    %JetzySchema.PG.User.Credential.JetzyLegacy.Table{
      identifier: identifier,
      login_name: settings.login_name,
      guid: settings.guid,
      password_hash: settings.password_hash,
      modified_on: %{modified_on| microsecond: {0, 6}}
    }
  end
  def __as_record__(layer, identifier, settings, context, options) do
    super(layer, identifier, settings, context, options)
  end



  #===----
  # Legacy MSSQL Password Encryption
  #===----
  @legacy_vi_key Application.get_env(:data, :legacy)[:legacy_vi_key]
  @legacy_password_hash Application.get_env(:data, :legacy)[:legacy_password_hash]
  @legacy_password_salt Application.get_env(:data, :legacy)[:legacy_password_salt]
  
  @aes_block_size 16

  def mssql_hash_key() do
    Plug.Crypto.KeyGenerator.generate(@legacy_password_hash, @legacy_password_salt, [iterations: 1000, length: 32, digest: :sha])
  end

  def decrypt_hash_password(hash) do
    with {:ok, bin} <- Base.decode64(hash) do
      password = :crypto.crypto_one_time(:aes_256_cbc, Jetzy.User.Credential.JetzyLegacy.mssql_hash_key(), @legacy_vi_key, bin, encrypt: false) |> String.trim_trailing(<<0>>)
      {:ok, password}
    else
      error -> error
    end
    rescue
    _ -> {:error, :internal_error}
    catch
    :exit, _ -> {:error, :internal_error}
    _ -> {:error, :internal_error}
  end

  def mssql_hash_password(password) do
    data = pad(password, @aes_block_size)
    :crypto.crypto_one_time(:aes_256_cbc, mssql_hash_key(), @legacy_vi_key, data, encrypt: true)
    |> Base.encode64()
  end

  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(0, to_add))
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  #---------------------------
  #
  #---------------------------
  def query_key(%__MODULE__{} = this), do: {:api_legacy, {this.guid, this.login_name, this.password_hash}}


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
    guid = setting.guid
    login_name = setting.login_name
    password_hash = setting.password_hash

    query = cond do
              password_hash && password_hash != :_ ->
                cond do
                  login_name && login_name != :_ && guid && guid != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.guid == ^guid,
                         where: c.login_name == ^login_name,
                         where: c.password_hash == ^password_hash,
                         select: c,
                         limit: 1
                  guid && guid != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.guid == ^guid,
                         where: c.password_hash == ^password_hash,
                         select: c,
                         limit: 1
                  login_name && login_name != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.login_name == ^login_name,
                         where: c.password_hash == ^password_hash,
                         select: c,
                         limit: 1
                  :else -> nil
                end
              :else ->
                cond do
                  login_name && login_name != :_ && guid && guid != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.guid == ^guid,
                         where: c.login_name == ^login_name,
                         select: c,
                         limit: 1
                  guid && guid != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.guid == ^guid,
                         select: c,
                         limit: 1
                  login_name && login_name != :_ ->
                    from c in JetzySchema.PG.User.Credential.JetzyLegacy.Table,
                         where: c.login_name == ^login_name,
                         select: c,
                         limit: 1
                  :else -> nil
                end
            end

    case query && JetzySchema.PG.Repo.all(query) do
      [record|_] -> Jetzy.User.Credential.Entity.ref(record.identifier)
      _ -> nil
    end
  end

end

