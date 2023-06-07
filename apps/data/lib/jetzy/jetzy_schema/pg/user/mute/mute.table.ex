defmodule JetzySchema.PG.User.Mute.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_mute)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_mute" do
    field :user, JetzySchema.Types.User.Reference
    field :mute, JetzySchema.Types.User.Reference

    field :status, :integer
    field :muted_on, :utc_datetime
    
    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
