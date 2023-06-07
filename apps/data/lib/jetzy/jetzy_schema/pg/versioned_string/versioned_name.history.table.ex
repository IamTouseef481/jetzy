defmodule JetzySchema.PG.VersionedName.History.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 21
  JetzySchema.NoizuTableBehaviour.table(:vnext_versioned_name_history)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_name_history" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference
    field :versioned_name, JetzySchema.Types.VersionedName.Reference

    field :revision, :integer

    field :first, JetzySchema.Types.Noizu.MarkdownField
    field :middle, JetzySchema.Types.Noizu.MarkdownField
    field :last, JetzySchema.Types.Noizu.MarkdownField

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end

end
