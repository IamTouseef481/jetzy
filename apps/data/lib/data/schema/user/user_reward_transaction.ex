defmodule Data.Schema.UserRewardTransaction do
  @moduledoc """
    The schema for User reward transaction
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        balance_point: float,
        is_canceled: boolean,
        is_completed: boolean,
        point: float,
        remarks: String.t | nil,
        reward_id: binary,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    reward_id
    point
    balance_point
    is_completed
    is_canceled
    remarks
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_reward_transactions" do
    field :balance_point, :float
    field :is_canceled, :boolean
    field :is_completed, :boolean
    field :point, :float
    field :remarks, :string
#    field :reward_id, :binary

    belongs_to :user, Data.Schema.User
    belongs_to :reward, Data.Schema.RewardManager

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:reward_id)
  end

  @nmid_index 583
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
