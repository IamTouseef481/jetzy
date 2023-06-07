defmodule JetzySchema.PG.Location.Redirect.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_redirect)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_redirect" do
    field :location, JetzySchema.Types.Universal.Reference
    field :redirect_to, JetzySchema.Types.Universal.Reference
    field :added_by, JetzySchema.Types.Universal.Reference
    field :note, JetzySchema.Types.LocationVersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime_usec
  end
end
