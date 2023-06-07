defmodule JetzySchema.PG.Device.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_device)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_device" do
    field :finger_print, :string
    field :device_uuid, :string
    field :operating_system, JetzySchema.Types.OperatingSystem.Reference
    field :device_type, JetzySchema.Types.Device.Type.Enum
    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
