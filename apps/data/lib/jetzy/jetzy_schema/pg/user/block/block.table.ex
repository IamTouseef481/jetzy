defmodule JetzySchema.PG.User.Block.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_block)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_block" do
    field :user, JetzySchema.Types.Universal.Reference
    field :block, JetzySchema.Types.Universal.Reference

    field :status, JetzySchema.Types.Status.Enum
    field :blocked_on, :utc_datetime

    field :reason, JetzySchema.Types.UserVersionedString.Reference


    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
