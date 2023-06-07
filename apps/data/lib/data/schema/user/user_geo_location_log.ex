defmodule Data.Schema.UserGeoLocationLog do
  @moduledoc """
    The schema for User geo location log
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
        log_created_on: :date,
        longitude: float,
        user_id: binary,
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
    log_created_on
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_geo_location_logs" do
    field :geo_location, Geo.PostGIS.Geometry
    field :is_actual_location, :boolean
    field :latitude, :float
    field :location, :string
    field :log_created_on, :date
    field :longitude, :float

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 563
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
