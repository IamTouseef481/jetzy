defmodule JetzySchema.PG.VersionedName.Table do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_versioned_name)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_name" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference

    field :revision, :integer

    field :first, JetzySchema.Types.Noizu.MarkdownField
    field :middle, JetzySchema.Types.Noizu.MarkdownField
    field :last, JetzySchema.Types.Noizu.MarkdownField

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end


  def delete_history(versioned_name, _context, _options \\ nil) do
    ref = Noizu.ERP.ref(versioned_name)
    delete_query = from h in JetzySchema.PG.VersionedName.History.Table,
                        where: h.versioned_name == ^ref
    JetzySchema.PG.Repo.delete_all(delete_query)
  end


end
