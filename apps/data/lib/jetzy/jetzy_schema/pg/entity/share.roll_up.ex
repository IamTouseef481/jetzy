defmodule JetzySchema.PG.Entity.Share.RollUp.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_share_roll_up)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false} # Same as Entity's Universal Identifier
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_share_roll_up" do
    field :tally, :integer

    #  Standard Time Stamps
    field :synchronized_on, :utc_datetime_usec
  end
end
