defmodule Data.Schema.RewardTier do
  @moduledoc """
    The schema for Reward tier
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        address: String.t | nil,
        description: String.t | nil,
        end_point: float,
        is_deleted: boolean,
        start_point: float,
        tier_name: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    tier_name
    description
    start_point
    end_point
    address
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "reward_tiers" do
    field :address, :string
    field :description, :string
    field :end_point, :float
    field :is_deleted, :boolean
    field :start_point, :float
    field :tier_name, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 535
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
