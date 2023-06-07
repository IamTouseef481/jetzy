defmodule Data.Schema.UserGeoLocation do
  @moduledoc """
    The schema for User geo location
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        geo_location: Geo.PostGIS.Geometry | nil,
        is_actual_location: boolean,
        latitude: float,
        location: String.t | nil,
        longitude: float,
        user_id: binary,
        city_lat_long_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    geo_location
    location
    latitude
    longitude
    is_actual_location
    city_lat_long_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_geo_locations" do
    field :geo_location, Geo.PostGIS.Geometry
    field :is_actual_location, :boolean
    field :latitude, :float
    field :location, :string
    field :longitude, :float

    belongs_to :user, Data.Schema.User
    belongs_to :city_lat_long, Data.Schema.CityLatLong

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:city_lat_long_id)
    |> unique_constraint(:user_id)
  end

  @nmid_index 562
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
