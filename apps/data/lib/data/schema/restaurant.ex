defmodule Data.Schema.Restaurant do
  @moduledoc """
    The schema for Restaurant
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        address: String.t | nil,
        is_deleted: boolean,
        latitude: float,
        longitude: float,
        restaurant_name: String.t | nil,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    restaurant_name
    user_id
    latitude
    longitude
    address
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "restaurants" do
    field :address, :string
    field :is_deleted, :boolean
    field :latitude, :float
    field :longitude, :float
    field :restaurant_name, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 531
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
