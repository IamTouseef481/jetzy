defmodule Data.Schema.NotificationSetting do
  @moduledoc """
    The schema for Notification setting
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_send_mail: boolean,
        is_send_notification: boolean,
        notification_type_id: binary,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    notification_type_id
    is_send_notification
    is_send_mail
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "notification_settings" do
    field :is_send_mail, :boolean
    field :is_send_notification, :boolean

    belongs_to :user, Data.Schema.User
    belongs_to :notification_type, Data.Schema.NotificationType

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:notification_type_id, :user_id], name: :user_notification_type_id)
  end

  @nmid_index 522
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
