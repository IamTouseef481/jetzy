defmodule JetzySchema.PG.Interest.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_interest)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_interest" do
    field :owner, JetzySchema.Types.Universal.Reference

    field :public, :boolean
    field :private_group, :boolean
    field :visibility, JetzySchema.Types.Visibility.Type.Enum
    field :color, :string
    field :slug, :string
    field :status, JetzySchema.Types.Status.Enum

    field :description, JetzySchema.Types.VersionedString.Reference
    field :details, JetzySchema.Types.Universal.Reference

    field :interest_image, JetzySchema.Types.Entity.Image.Reference

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
