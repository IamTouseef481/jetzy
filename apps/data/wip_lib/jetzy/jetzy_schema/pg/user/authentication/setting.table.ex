defmodule JetzySchema.PG.User.Authentication.Setting.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_authentication_setting)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_authentication_setting" do
    field :user, JetzySchema.Types.User.Reference
    field :device, JetzySchema.Types.User.Device.Reference
    field :credential, JetzySchema.Types.User.Credential.Reference

    field :weight, :integer

    field :description, JetzySchema.Types.UserVersionedString.Reference
    field :status, JetzySchema.Types.Status.Enum
    field :setting, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
