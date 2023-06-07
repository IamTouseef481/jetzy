defmodule Data.Schema.UserFilter do
  @moduledoc """
    The schema for User filter
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        age_from: integer,
        age_to: integer,
        distance: float,
        distance_type: String.t | nil,
        gender: String.t | nil,
        interests: String.t | nil,
        is_friend: boolean,
        is_local: boolean,
        is_not_friend: boolean,
        is_traveler: boolean,
        location: String.t | nil,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    gender
    age_from
    age_to
    is_local
    is_traveler
    is_not_friend
    is_friend
    location
    distance
    distance_type
    interests
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_filters" do
    field :age_from, :integer
    field :age_to, :integer
    field :distance, :float
    field :distance_type, :string
    field :gender, :string
    field :interests, :string
    field :is_friend, :boolean
    field :is_local, :boolean
    field :is_not_friend, :boolean
    field :is_traveler, :boolean
    field :location, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 559
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
