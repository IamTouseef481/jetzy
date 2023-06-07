defmodule JetzySchema.PG.Location.Relation.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_relation)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_relation" do

    field :location, JetzySchema.Types.Universal.Reference
    field :location_relation, JetzySchema.Types.Universal.Reference
    field :location_relation_type, JetzySchema.Types.Location.Relation.Type.Enum
    field :added_by, JetzySchema.Types.Universal.Reference
    field :description, JetzySchema.Types.LocationVersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
