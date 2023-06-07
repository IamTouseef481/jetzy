defmodule Data.Schema.GuestInterest do
  @moduledoc """
    The schema for Admin
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               device_id: String.t | nil,
               interest_id: binary

             }

  @required_fields ~w|
    interest_id
  |a

  @optional_fields ~w|
    deleted_at
    device_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "guest_interest" do
    field :device_id, :string
    belongs_to(:interest, Data.Schema.Interest)
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 516
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
