defmodule JetzySchema.PG.System.Event.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_system_event)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_system_event" do
    field :system_event_type, JetzySchema.Types.System.Event.Type.Enum
    field :points, :integer

    field :description, JetzySchema.Types.VersionedString.Reference
    field :details, JetzySchema.Types.Universal.Reference # CMS

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
