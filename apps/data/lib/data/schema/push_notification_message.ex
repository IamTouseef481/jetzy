defmodule Data.Schema.PushNotificationMessage do
  @moduledoc """
    The schema for Register user with private interest
  """
  use Data.Schema

  @type t :: %__MODULE__{
               id: String.t(),
               message: String.t() | nil,
             }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    id
    message
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields

  @primary_key false
  schema "push_notification_message" do
    field :id, :string, primary_key: true
    field :message, :string

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

end
