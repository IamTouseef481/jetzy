defmodule Data.Schema.RoomReferralCode do
  @moduledoc """
    The schema for Room Referral Code
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @required_fields ~w|
    referral_code
    room_id
  |a

  @optional_fields ~w|
    user_id
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "room_referral_code" do
    field(:referral_code, :string)

    belongs_to :room, Data.Schema.Room
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:referral_code)
  end
  @nmid_index 598
  use Data.Schema.TanbitsEntity, sref: "t-room-msg"
end
