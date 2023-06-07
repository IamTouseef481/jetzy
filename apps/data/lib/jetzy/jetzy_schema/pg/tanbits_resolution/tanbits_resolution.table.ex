defmodule JetzySchema.PG.TanbitsResolution.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_tanbits_identifier_mapping)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_tanbits_identifier_mapping" do
    field :source, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :source_identifier, :integer

    field :tanbits_source, JetzySchema.Types.TanbitsResolution.Source.Enum
    field :tanbits_integer_identifier, :integer
    field :tanbits_guid_identifier, Ecto.UUID
    field :tanbits_string_identifier, :string
    field :tanbits_sub_identifier, :integer
  end
end

