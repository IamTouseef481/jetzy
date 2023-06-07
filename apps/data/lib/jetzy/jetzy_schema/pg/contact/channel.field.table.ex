defmodule JetzySchema.PG.Contact.Channel.Field.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_contact_channel_field)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_contact_channel_field" do
    field :contact_channel, JetzySchema.Types.Contact.Channel.Reference
    field :channel_definition_field, JetzySchema.Types.Channel.Field.Type.Enum
    field :value, :string
    field :modified_on, :utc_datetime
  end
end
