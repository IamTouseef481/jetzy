defmodule JetzySchema.PG.Import.Error.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_import_error)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_legacy_import_error" do
    field :status, JetzySchema.Types.Status.Enum

    field :import_error_type, JetzySchema.Types.Import.Error.Type.Enum
    field :import_error_section, JetzySchema.Types.Import.Error.Section.Enum

    field :error_message, JetzySchema.Types.VersionedString.Reference
    field :debug_comment, JetzySchema.Types.VersionedString.Reference

    field :source, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :source_identifier, :integer

    field :legacy_source, JetzySchema.Types.LegacyResolution.Source.Enum
    field :legacy_integer_identifier, :integer
    field :legacy_guid_identifier, Ecto.UUID
    field :legacy_string_identifier, :string
    field :legacy_sub_identifier, :integer

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end

