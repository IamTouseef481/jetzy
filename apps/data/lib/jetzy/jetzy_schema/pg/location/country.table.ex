defmodule JetzySchema.PG.Location.Country.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_country)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_country" do
    field :status, JetzySchema.Types.Status.Enum
    field :name, :string
    field :details, JetzySchema.Types.Universal.Reference

    field :iso_3166_code, :string
    field :flag_emoji, :string

    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer
    field :geo_geometry, Geo.PostGIS.Geometry

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
