defmodule JetzySchema.PG.Repo do


  use Ecto.Repo,
      otp_app: :api,
      adapter: Ecto.Adapters.Postgres
  #----------------------------
  #
  #----------------------------
  defp build_opts(opts) do
    system_opts = Application.get_env(:data, JetzySchema.PG.Repo)
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
    JetzySchema.PG.Repo.insert(record, on_conflict: :replace_all, conflict_target: [:identifier])
  end

  #----------------------------
  #
  #----------------------------
  def tables() do
    Jetzy.DomainObject.Schema.__noizu_info__(:tables)
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
  def metadata(), do: %Noizu.AdvancedScaffolding.Schema.Metadata.Ecto{repo: __MODULE__, database: JetzySchema.PG}
end

