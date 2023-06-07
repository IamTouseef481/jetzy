defmodule Data.Schema.NotificationType do
  @moduledoc """
    The schema for Notification type
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        description: String.t | nil,
        is_deleted: boolean,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    description
    is_deleted
    event
    message
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "notification_types" do
    field :description, :string
    field :message, :string
    field :event, :string
    field :is_deleted, :boolean


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 523
  use Data.Schema.TanbitsEntity, sref: "t-notification-type"
end
