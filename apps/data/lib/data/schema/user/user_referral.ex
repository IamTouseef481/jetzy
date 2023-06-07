defmodule Data.Schema.UserReferral do
  @moduledoc """
    The schema for User referral
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               is_accept: boolean,
               referred_to: String.t | nil,
               referral_code: String.t | nil,
               referred_from_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    referred_to
    referred_from_id
    referral_code
    is_accept
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_referrals" do
    field :is_accept, :boolean
    field :referred_to, :string
    field :referral_code, :string

    belongs_to :referred_from, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:referral_code)
  end

  @nmid_index 581
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
