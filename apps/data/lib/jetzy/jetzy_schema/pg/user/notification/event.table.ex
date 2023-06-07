defmodule JetzySchema.PG.User.Notification.Event.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_notification_event)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_notification_event" do
    field :user, JetzySchema.Types.Universal.Reference
    field :sender, JetzySchema.Types.Universal.Reference
    field :subject, JetzySchema.Types.Universal.Reference
    field :notification_type, JetzySchema.Types.User.Notification.Type.Enum

    field :status, JetzySchema.Types.Status.Enum
    field :viewed_on, :utc_datetime
    field :cleared_on, :utc_datetime

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
