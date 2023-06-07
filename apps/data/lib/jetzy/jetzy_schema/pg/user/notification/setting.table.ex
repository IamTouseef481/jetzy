defmodule JetzySchema.PG.User.Notification.Setting.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_notification_setting)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_notification_setting" do
    field :user, JetzySchema.Types.Universal.Reference
    field :notification_type, JetzySchema.Types.User.Notification.Type.Enum

    field :sms_delivery_type, JetzySchema.Types.Notification.Delivery.Type.Enum
    field :push_delivery_type, JetzySchema.Types.Notification.Delivery.Type.Enum
    field :email_delivery_type, JetzySchema.Types.Notification.Delivery.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
