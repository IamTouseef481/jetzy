defmodule Data.Schema.UserFollow do
  @moduledoc """
    The schema for User follow
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               followed_id: binary,
               follower_id: binary,
               follow_status: String.t | nil
             }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    follower_id
    followed_id
    follow_status

    deleted_at
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_follows" do

    field :follow_status, Ecto.Enum, values: [:requested, :followed, :blocked, :unfollowed, :cancelled]
    belongs_to :followed, Data.Schema.User
    belongs_to :follower, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 560
  use Data.Schema.TanbitsEntity, sref: "t-user-follow"
end
