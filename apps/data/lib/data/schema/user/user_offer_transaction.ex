defmodule Data.Schema.UserOfferTransaction do
  @moduledoc """
    The schema for User offer transaction
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
        offer_id: String.t | nil,
        point: float,
        remarks: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    offer_id
    point
    balance_point
    is_completed
    is_canceled
    remarks
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_offer_transactions" do
    field :balance_point, :float
    field :is_canceled, :boolean
    field :is_completed, :boolean
    field :offer_id, Ecto.UUID
    field :point, :float
    field :remarks, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)

  end

  @nmid_index 573
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
