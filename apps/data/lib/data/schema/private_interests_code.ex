defmodule Data.Schema.PrivateInterestsCode do
  @moduledoc """
    The schema for Private interests code
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        referal_code: String.t | nil,
        interest: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    referal_code
    interest_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "private_interests_codes" do
    field :referal_code, :string

    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 527
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
