defmodule JetzySchema.PG.User.Device.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_device)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_device" do
    field :user, JetzySchema.Types.User.Reference
    field :device, JetzySchema.Types.Device.Reference
    field :weight, :integer
    field :description, JetzySchema.Types.UserVersionedString.Reference
    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
