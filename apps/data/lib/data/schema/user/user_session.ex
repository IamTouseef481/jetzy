defmodule Data.Schema.UserSession do
  @moduledoc """
    The schema for User session
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        device_id: String.t | nil,
        is_active: boolean,
        last_access_date: :date,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    device_id
    last_access_date
    is_active
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_sessions" do
    field :device_id, :string
    field :is_active, :boolean
    field :last_access_date, :date

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 585
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
