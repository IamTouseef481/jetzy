defmodule JetzySchema.PG.Entity.Subject.Comment.History.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_subject_comment_history)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_subject_comment_history" do
    field :for_entity, JetzySchema.Types.Universal.Reference
    field :subject, JetzySchema.Types.Universal.Reference

    field :comment, JetzySchema.Types.Universal.Reference
    field :comment_event_type, JetzySchema.Types.Comment.Event.Type.Enum
    field :count, :integer

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end
end
