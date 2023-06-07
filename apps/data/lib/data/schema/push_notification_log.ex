defmodule Data.Schema.PushNotificationLog do
  @moduledoc """
    The schema for Push notification log
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        api_version: integer,
        app_version: String.t | nil,
        device_id: String.t | nil,
        device_type: integer,
        push_message: String.t | nil,
        push_token: String.t | nil,
        notification_type_id: binary,
        sender_id: binary,
        receiver_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    sender_id
    receiver_id
    notification_type_id
    push_message
    push_token
    device_id
    device_type
    api_version
    app_version
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "push_notification_logs" do
    field :api_version, :integer
    field :app_version, :string
    field :device_id, :string
    field :device_type, :integer
    field :push_message, :string
    field :push_token, :string

    belongs_to :sender, Data.Schema.User
    belongs_to :receiver, Data.Schema.User
    belongs_to :notification_type, Data.Schema.NotificationType

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:receiver_id)
    |> foreign_key_constraint(:notification_type_id)
  end

  @nmid_index 528
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
