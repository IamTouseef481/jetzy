defmodule JetzySchema.PG.Entity.Subject.Reaction.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_subject_reaction)

  @primary_key false
  schema "vnext_entity_subject_reaction" do
    field :for_entity, JetzySchema.Types.Universal.Reference, primary_key: true
    field :subject, JetzySchema.Types.Universal.Reference, primary_key: true


    field :history_event, JetzySchema.Types.Entity.Subject.Reaction.History.Reference
    field :reaction, JetzySchema.Types.Reaction.Type.Enum


    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end
end
