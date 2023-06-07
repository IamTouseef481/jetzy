defmodule JetzySchema.PG.Data.Source.IdentifierMap.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 11
  JetzySchema.NoizuTableBehaviour.table(:vnext_data_source_id_map)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_data_source_id_map" do

    field :data_source_provider, JetzySchema.Types.Data.Source.Enum
    field :data_source_type, JetzySchema.Types.Data.Source.Type.Enum
    field :data_source_identifier, :integer

    field :universal_identifier, JetzySchema.Types.Universal.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
