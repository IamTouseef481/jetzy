defmodule Data.Schema.UserShoutoutInterest do
  @moduledoc """
    The schema for User shoutout interest
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        user_id: binary,
        interest_id: binary,
        shoutout_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    shoutout_id
    user_id
    interest_id
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutout_interests" do

    belongs_to :shoutout, Data.Schema.UserShoutout
    belongs_to :user, Data.Schema.User
    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 590
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
