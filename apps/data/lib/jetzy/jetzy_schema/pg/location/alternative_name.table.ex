defmodule JetzySchema.PG.Location.AlternativeName.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_alternative_name)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_alternative_name" do
    field :location, JetzySchema.Types.Universal.Reference
    field :added_by, JetzySchema.Types.Universal.Reference
    field :alternative_name, JetzySchema.Types.LocationVersionedString.Reference
    field :status, JetzySchema.Types.Status.Enum

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :content_flag, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
