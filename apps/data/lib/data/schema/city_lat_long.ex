defmodule Data.Schema.CityLatLong do
  @moduledoc """
    The schema for City lat long
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        city: String.t | nil,
        country: String.t | nil,
        latitude: float,
        location: String.t | nil,
        longitude: float,
        state: String.t | nil,
        zip_code: String.t | nil,
        
    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    city
    state
    country
    zip_code
    location
    latitude
    longitude
    inserted_at
    updated_at
    
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "city_lat_longs" do
    field :city, :string
    field :country, :string
    field :latitude, :float
    field :location, :string
    field :longitude, :float
    field :state, :string
    field :zip_code, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 507
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
