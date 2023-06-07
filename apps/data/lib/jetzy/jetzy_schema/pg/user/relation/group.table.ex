defmodule JetzySchema.PG.User.Relation.Group.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_relation_group)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_relation_group" do
    field :description, JetzySchema.Types.VersionedString.Reference
    field :user, JetzySchema.Types.Universal.Reference
    field :user_relation_group_type, JetzySchema.Types.User.Relation.Group.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
