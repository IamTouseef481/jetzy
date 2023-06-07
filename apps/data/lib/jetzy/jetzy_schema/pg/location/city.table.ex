defmodule JetzySchema.PG.Location.City.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_city)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_city" do
    field :location_country, JetzySchema.Types.Location.Country.Reference
    field :location_state, JetzySchema.Types.Location.State.Reference
    field :status, JetzySchema.Types.Status.Enum
    field :name, :string
    field :details, JetzySchema.Types.Universal.Reference

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
