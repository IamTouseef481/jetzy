defmodule Data.Schema.UserEmergencyContact do
  @moduledoc """
    The schema for User emergency contact
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_active: boolean,
        user_email: String.t | nil,
        user_first_name: String.t | nil,
        user_last_name: String.t | nil,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_first_name
    user_last_name
    user_email
    user_id
    is_active
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_emergency_contacts" do
    field :is_active, :boolean
    field :user_email, :string
    field :user_first_name, :string
    field :user_last_name, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 552
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
