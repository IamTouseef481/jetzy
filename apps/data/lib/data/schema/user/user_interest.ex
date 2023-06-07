defmodule Data.Schema.UserInterest do
  @moduledoc """
    The schema for User interest
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_active: boolean,
        is_admin: boolean,
        user_id: binary,
        interest_id: binary,
    }

  @required_fields ~w|
    user_id
    interest_id
  |a

  @optional_fields ~w|
    deleted_at
    is_admin
    is_active
    inserted_at
    updated_at
    status
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_interests" do
    field :is_active, :boolean
    field :is_admin, :boolean
    field :status, Ecto.Enum, values: [:pending, :accepted, :cancelled, :rejected, :blocked], default: :accepted
    belongs_to :user, Data.Schema.User
    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:interest_id)
    |> foreign_key_constraint(:user_id)
  end

  def by_legacy(guid, context, options \\ []) do
    Jetzy.TanbitsResolution.Repo.by_legacy(Data.Schema.UserInterest, guid, context, options)
    |> Noizu.ERP.entity
  end
  def by_legacy!(guid, context, options \\ []) do
    Jetzy.TanbitsResolution.Repo.by_legacy!(Data.Schema.UserInterest, guid, context, options)
    |> Noizu.ERP.entity!
  end

  @nmid_index 566
  use Data.Schema.TanbitsEntity, sref: "t-user-interest"
end
