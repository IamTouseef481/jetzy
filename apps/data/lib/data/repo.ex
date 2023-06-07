defmodule Data.Repo do
  use Ecto.Repo,
    otp_app: :data,
    adapter: Ecto.Adapters.Postgres
    
  use Scrivener, page_size: 10

  #----------------------------
  #
  #----------------------------
  # Hack pending ECTO support of Generated columns
  def upsert(%Ecto.Changeset{data: table} = record) do
    cond do
      !function_exported?(table.__struct__, :__extended_schema__, 1) ->
        Data.Repo.insert(record, on_conflict: :replace_all, conflict_target: [:id])
      :else ->
        case table.__struct__.__extended_schema__(:generated_fields) do
          [] ->
            Data.Repo.insert(record, on_conflict: :replace_all, conflict_target: [:id])
          generated_fields when is_list(generated_fields) ->
            Data.Repo.insert(record, on_conflict: {:replace_all_except,generated_fields}, conflict_target: [:id])
        end
    end
  end
  def upsert(record) do
    cond do
      !function_exported?(record.__struct__, :__extended_schema__, 1) ->
        Data.Repo.insert(record, on_conflict: :replace_all, conflict_target: [:id])
      :else ->
        case record.__struct__.__extended_schema__(:generated_fields) do
          [] ->
            Data.Repo.insert(record, on_conflict: :replace_all, conflict_target: [:id])
          generated_fields when is_list(generated_fields) ->
            Data.Repo.insert(record, on_conflict: {:replace_all_except,generated_fields}, conflict_target: [:id])
        end
    end
  end

  
  
  #----------------------------
  #
  #----------------------------
  def tables() do
    Jetzy.DomainObject.Schema.__noizu_info__(:tanbits_entity)
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
  def metadata(), do: %Noizu.AdvancedScaffolding.Schema.Metadata.Ecto{repo: __MODULE__, database: Data}
end
