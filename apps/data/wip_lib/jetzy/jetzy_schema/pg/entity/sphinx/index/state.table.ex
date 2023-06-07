defmodule JetzySchema.PG.Entity.Sphinx.Index.State.Table do
  @moduledoc """
  table defined in  liquibase/1.0/003_content.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  import Ecto.Query, only: [from: 2]

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_sphinx_index_state)

  @primary_key {:identifier, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_sphinx_index_state" do
    field :subject_type, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :subject_identifier, JetzySchema.Types.Universal.Reference

    field :sphinx_index, :integer # JetzySchema.Types.Sphinx.Index.Reference
    field :sphinx_index_type, JetzySchema.Types.Sphinx.Index.Type.Enum
    field :pending_index_type, JetzySchema.Types.Sphinx.Index.Type.Enum

    field :modified_on, :utc_datetime
  end

  def subject(%{subject_identifier: subject_identifier}, _context, _options) do
    Noizu.ERP.entity!(subject_identifier)
  end

  def clear_pending_type(index, pending_type, _context, _options) do
    query = query_for_pending_type(index, pending_type)
    JetzySchema.PG.Repo.update_all(query, set: [pending_index_type: :none])
  end

  def set_pending_type(index, index_type, pending_type, _context, _options) do
    query = query_for_type(index, index_type)
    JetzySchema.PG.Repo.update_all(query, set: [pending_index_type: pending_type])
  end

  def pending_records(index, index_type, page, rpp, context, options) do
    query = query_for_pending_type(index, index_type)
            |> paginate(page, rpp)
    JetzySchema.PG.Repo.all(query) |> expand_records(context, options)
  end

  defp expand_records(records, _context, _options) do
    Enum.map(records, fn(record) ->
      %{record| subject_identifier: Noizu.ERP.entity!(record.subject_identifier)}
    end)
  end

  defp paginate(query, page, rpp) do
    from query,
    limit: ^rpp,
    offset: ^(page * rpp)
  end

  defp query_for_pending_type(index, type) do
    index = index.__index_identifier__()
    from i in JetzySchema.PG.Entity.Sphinx.Index.State.Table,
         where: i.sphinx_index == ^index,
         where: i.pending_index_type == ^type
  end

  def query_for_type(index, type) do
    index = index.__index_identifier__()
    from i in JetzySchema.PG.Entity.Sphinx.Index.State.Table,
         where: i.sphinx_index == ^index,
         where: i.sphinx_index_type == ^type,
         where: i.pending_index_type == :none
  end

end
