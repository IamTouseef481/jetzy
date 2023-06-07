defmodule Data.Schema.UserPushToken do
  @moduledoc """
    The schema for User push token
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        device_id: String.t | nil,
        device_type: String.t | nil,
        language: String.t | nil,
        push_token: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    device_id
    push_token
    device_type
    language
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_push_tokens" do
    field :device_id, :string
    field :device_type, :string
    field :language, :string
    field :push_token, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 579
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
