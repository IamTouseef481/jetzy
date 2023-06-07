defmodule JetzySchema.PG.Entity.Reaction.RollUp.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_reaction_roll_up)

  @primary_key false
  schema "vnext_entity_reaction_roll_up" do
    field :subject, JetzySchema.Types.Universal.Reference, primary_key: true
    field :reaction, JetzySchema.Types.Reaction.Type.Enum, primary_key: true
    field :tally, :integer

    #  Standard Time Stamps
    field :synchronized_on, :utc_datetime_usec
  end
end
