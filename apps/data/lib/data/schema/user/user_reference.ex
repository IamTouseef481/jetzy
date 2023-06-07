defmodule Data.Schema.UserReference do
  @moduledoc """
    The schema for User reference
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        user_referral_code: String.t | nil,
        user_interest_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_referral_code
    user_interest_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_references" do
    field :user_referral_code, :string

    belongs_to :user_interest, Data.Schema.UserInterest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_interest_id)
  end

  @nmid_index 580
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
