defmodule JetzySchema.PG.VersionedLink.Table do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_versioned_link)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_link" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference

    field :revision, :integer
    field :name, JetzySchema.Types.Noizu.MarkdownField
    field :description, JetzySchema.Types.Noizu.MarkdownField
    field :link, JetzySchema.Types.Noizu.MarkdownField

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end


  def delete_history(ref, _context, _options \\ nil) do
    ref = Noizu.ERP.ref(ref)
    delete_query = from h in JetzySchema.PG.VersionedLink.History.Table,
                        where: h.versioned_link == ^ref
    JetzySchema.PG.Repo.delete_all(delete_query)
  end

end
