defmodule JetzySchema.MSSQL.Repo do
  use Ecto.Repo,
      otp_app: :api,
      adapter: Ecto.Adapters.Tds
  #----------------------------
  #
  #----------------------------
  defp build_opts(opts) do
    system_opts = [
      hostname: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:hostname],
      database: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:database],
      username: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:username],
      password: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:password],
      port: 1433,
      timeout: 1000000,
      show_sensitive_data_on_connection_error: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:show_sensitive_data_on_connection_error]
    ]

    Keyword.merge(opts, system_opts)
  end

  #----------------------------
  #
  #----------------------------
  def init(_, opts) do
    {:ok, build_opts(opts)}
  end

  #----------------------------
  #
  #----------------------------
  def upsert(record) do
    JetzySchema.MSSQL.Repo.insert(record, on_conflict: :replace_all)
  end

  #----------------------------
  #
  #----------------------------
  def tables() do
    Jetzy.DomainObject.Schema.__noizu_info__(:mssql_tables)
  end

  #----------------------------
  #
  #----------------------------
  def create_handler(%{__struct__: _table} = record, _context, options) do
    cond do
      options[:with_upsert!] -> upsert(record)
      :else -> insert(record)
    end
  end

  #----------------------------
  #
  #----------------------------
  def create_handler!(%{__struct__: _table} = record, _context, options) do
    cond do
      options[:with_upsert!] -> upsert(record)
      :else -> insert(record)
    end
  end

  #----------------------------
  #
  #----------------------------
  def update_handler(%{__struct__: table} = record, context, options) do
    cond do
      options[:with_upsert!] -> upsert(record)
      :else ->
        changeset = table.changeset(record, context, options)
        __MODULE__.update(changeset)
    end
  end

  #----------------------------
  #
  #----------------------------
  def update_handler!(%{__struct__: table} = record, context, options) do
    cond do
      options[:with_upsert!] -> upsert(record)
      :else ->
        changeset = table.changeset(record, context, options)
        __MODULE__.update(changeset)
    end
  end

  #----------------------------
  #
  #----------------------------
  def delete_handler(%{__struct__: table} = record, _context, _options) do
    delete(table, record.identifier)
  end

  #----------------------------
  #
  #----------------------------
  def delete_handler!(%{__struct__: table} = record, _context, _options) do
    delete(table, record.identifier)
  end

  #----------------------------
  #
  #----------------------------
  def metadata(), do: %Noizu.AdvancedScaffolding.Schema.Metadata.Ecto{repo: __MODULE__, database: JetzySchema.MSSQL}
end
