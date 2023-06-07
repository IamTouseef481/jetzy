defmodule JetzySchema.PG.UniversalIdentifierResolution.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_universal_identifier_resolution)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_universal_identifier_resolution" do
    field :source, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :source_identifier, :integer
    field :source_uuid, Ecto.UUID
  end
end
