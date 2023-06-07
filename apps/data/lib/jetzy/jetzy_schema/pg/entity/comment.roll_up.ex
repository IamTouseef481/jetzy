defmodule JetzySchema.PG.Entity.Comment.RollUp.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_comment_roll_up)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false} # Same as Entity's Universal Identifier
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_comment_roll_up" do
    field :tally, :integer
    field :subject_type, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    #  Standard Time Stamps
    field :synchronized_on, :utc_datetime_usec
  end
end
