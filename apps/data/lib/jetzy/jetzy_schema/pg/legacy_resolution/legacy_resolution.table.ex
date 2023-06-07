defmodule JetzySchema.PG.LegacyResolution.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_legacy_identifier_mapping)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_legacy_identifier_mapping" do
    field :source, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :source_identifier, :integer

    field :legacy_source, JetzySchema.Types.LegacyResolution.Source.Enum
    field :legacy_integer_identifier, :integer
    field :legacy_guid_identifier, Ecto.UUID
    field :legacy_string_identifier, :string
    field :legacy_sub_identifier, :integer
  end
end

