defmodule JetzySchema.PG.Location.Place.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_place)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_place" do
    field :location_country, JetzySchema.Types.Location.Country.Reference
    field :location_state, JetzySchema.Types.Location.State.Reference
    field :location_city, JetzySchema.Types.Location.City.Reference
    field :location_type, JetzySchema.Types.Location.Type.Enum
    field :status, JetzySchema.Types.Status.Enum
    field :address, JetzySchema.Types.VersionedAddress.Reference
    field :details, JetzySchema.Types.Universal.Reference
    field :place_key, :string

    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer
    field :geo_geometry, Geo.PostGIS.Geometry

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
