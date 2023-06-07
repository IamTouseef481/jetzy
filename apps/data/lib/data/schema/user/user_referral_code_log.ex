defmodule Data.Schema.UserReferralCodeLog do

   @moduledoc """
    The schema for User Referral Code Log
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        referral_code: String.t,
        user_id: Ecto.UUID
    }

  @required_fields ~w|
      referral_code
      user_id
  |a

  @optional_fields ~w|
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_referral_code_logs" do
    field :referral_code, :string
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:referral_code)
  end

  @nmid_index 591
  use Data.Schema.TanbitsEntity, sref: "t-user-referral-code-log"

end
