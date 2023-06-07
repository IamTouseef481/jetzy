defmodule JetzySchema.PG.Group.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_group)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_group" do
    field :visibility, JetzySchema.Types.Visibility.Type.Enum
    field :description, JetzySchema.Types.VersionedString.Reference
    field :details, JetzySchema.Types.Universal.Reference # CMS

    field :status, JetzySchema.Types.Status.Enum

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
