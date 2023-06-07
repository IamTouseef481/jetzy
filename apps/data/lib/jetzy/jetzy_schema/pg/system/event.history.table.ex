defmodule JetzySchema.PG.System.Event.History.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_system_event_history)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_system_event_history" do

    field :user, JetzySchema.Types.Universal.Reference # CMS
    field :system_event, JetzySchema.Types.System.Event.Reference
    field :transaction, JetzySchema.Types.Universal.Reference # CMS

    field :note, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
