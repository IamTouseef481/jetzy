defmodule JetzySchema.PG.VersionedLink.History.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 20
  JetzySchema.NoizuTableBehaviour.table(:vnext_versioned_link_history)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_link_history" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference
    field :versioned_link, JetzySchema.Types.VersionedLink.Reference

    field :revision, :integer
    field :name, JetzySchema.Types.Noizu.MarkdownField
    field :description, JetzySchema.Types.Noizu.MarkdownField
    field :link, JetzySchema.Types.Noizu.MarkdownField

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end
end
