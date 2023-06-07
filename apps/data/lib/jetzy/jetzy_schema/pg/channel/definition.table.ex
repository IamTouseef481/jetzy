defmodule JetzySchema.PG.Channel.Definition.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_channel_definition)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_channel_definition" do
    field :handle, :string
    field :channel_handler, JetzySchema.Types.Channel.Handler.Enum
    field :description, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
