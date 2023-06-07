defmodule JetzySchema.PG.User.Relation.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_relation)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_relation" do
    field :user, JetzySchema.Types.Universal.Reference
    field :relation, JetzySchema.Types.Universal.Reference

    field :friend, JetzySchema.Types.Universal.Reference
    field :friend_status, JetzySchema.Types.Status.Enum

    field :follow, JetzySchema.Types.Universal.Reference
    field :follow_status, JetzySchema.Types.Status.Enum
    field :followed, JetzySchema.Types.Universal.Reference
    field :followed_status, JetzySchema.Types.Status.Enum

    field :mute, JetzySchema.Types.Universal.Reference
    field :mute_status, JetzySchema.Types.Status.Enum
    field :muted, JetzySchema.Types.Universal.Reference
    field :muted_status, JetzySchema.Types.Status.Enum

    field :block, JetzySchema.Types.Universal.Reference
    field :block_status, JetzySchema.Types.Status.Enum
    field :blocked, JetzySchema.Types.Universal.Reference
    field :blocked_status, JetzySchema.Types.Status.Enum

    field :relative, JetzySchema.Types.Universal.Reference
    field :relative_status, JetzySchema.Types.Status.Enum
    field :relative_type, JetzySchema.Types.Relative.Type.Enum

    field :relationship, JetzySchema.Types.Universal.Reference
    field :relationship_status, JetzySchema.Types.Status.Enum
    field :relationship_type, JetzySchema.Types.Relationship.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
