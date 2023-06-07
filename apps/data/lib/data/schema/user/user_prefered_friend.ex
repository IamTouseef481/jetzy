defmodule Data.Schema.UserPreferedFriend do
  @moduledoc """
    The schema for User prefered friend
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        user_id: binary,
        friend_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    friend_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_prefered_friends" do

    belongs_to :user, Data.Schema.User
    belongs_to :friend, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 509
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
