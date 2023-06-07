defmodule Data.Schema.RoomUser do
  @moduledoc """
    The schema for Room user
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
          id: binary,
          user_id: binary,
          room_id: binary,
          user_role: String.t | nil
        }

  @required_fields ~w|
    user_id
    room_id

    |a

  @optional_fields ~w|
    inserted_at
    updated_at
    user_role
    |a

  @all_fields @required_fields ++ @optional_fields

  schema "room_users" do
    belongs_to(:user, Data.Schema.User)
    belongs_to(:room, Data.Schema.Room)
    field :user_role, :string

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(@required_fields)

  end

  @nmid_index 540
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
