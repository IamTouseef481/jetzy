defmodule JetzySchema.PG.LegacyResolution.Source.Enum.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_legacy_resolution_source)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_legacy_resolution_source" do
    field :table_name, :string
    field :ecto_name, :string
    field :description, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
