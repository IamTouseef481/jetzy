defmodule JetzySchema.PG.Location.Source.Google.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_source_google)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_source_google" do

    field :location, JetzySchema.Types.Universal.Reference
    field :location_type, JetzySchema.Types.Location.Type.Enum
    field :added_by, JetzySchema.Types.Universal.Reference

    field :hash, :string
    field :place, :string
    field :url, :string
    field :icon, :string
    field :address, :string
    field :raw, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
