defmodule JetzySchema.PG.Entity.Subject.Share.History.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_subject_share_history)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_subject_share_history" do
    field :for_entity, JetzySchema.Types.Universal.Reference
    field :subject, JetzySchema.Types.Universal.Reference

    field :share, JetzySchema.Types.Universal.Reference
    field :share_event_type, JetzySchema.Types.Share.Event.Type.Enum
    field :count, :integer

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
  end
end
