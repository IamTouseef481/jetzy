defmodule JetzySchema.PG.Location.Source.Legacy.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_source_legacy)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_source_legacy" do
    field :location, JetzySchema.Types.Universal.Reference
    field :location_type, JetzySchema.Types.Location.Type.Enum
    field :added_by, JetzySchema.Types.Universal.Reference

    field :legacy_record, JetzySchema.Types.LegacyResolution.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime_usec
  end
end
