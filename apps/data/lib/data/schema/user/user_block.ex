defmodule Data.Schema.UserBlock do
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
        is_blocked: boolean,
        user_from_id: String.t | nil,
        user_to_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    user_from_id
    user_to_id
    is_blocked

    deleted_at
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_blocks" do
    field :is_blocked, :boolean

    belongs_to :user_from, Data.Schema.User
    belongs_to :user_to, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 549
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
