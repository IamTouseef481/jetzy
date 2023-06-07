defmodule Data.Schema.UserFriend do
  @moduledoc """
    The schema for User friend
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        friend_blocked: boolean,
        is_blocked: boolean,
        is_friend: boolean,
        is_request_sent: boolean,
        user_id: binary,
        friend_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    friend_id
    is_friend
    is_request_sent
    is_blocked
    friend_blocked
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_friends" do
    field :friend_blocked, :boolean
    field :is_blocked, :boolean
    field :is_friend, :boolean
    field :is_request_sent, :boolean

    belongs_to :user, Data.Schema.User
    belongs_to :friend, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:friend_id)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 561
  use Data.Schema.TanbitsEntity, sref: "t-user-friend"
end