defmodule JetzySchema.PG.Channel.Definition.Field.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 3
  JetzySchema.NoizuTableBehaviour.table(:vnext_channel_definition_field)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_channel_definition_field" do

    field :channel_definition, JetzySchema.Types.Channel.Definition.Reference
    field :field_type, JetzySchema.Types.Channel.Field.Type.Enum
    field :validation, :string
    field :weight, :integer
    field :description, JetzySchema.Types.VersionedString.Reference
    #  Standard Time Stamps
    field :modified_on, :utc_datetime
  end
end
