defmodule JetzySchema.PG.Entity.Interactions.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_interactions.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_interaction_cache)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_interaction" do

    field :comments, :integer
    field :shares, :integer

    field :like, :integer
    field :dislike, :integer
    field :heart, :integer
    field :angry, :integer
    field :sad, :integer
    field :laugh, :integer
    field :confused, :integer
    field :comfort, :integer
    field :reaction_09, :integer
    field :reaction_10, :integer

    #  Standard Time Stamps
    field :synchronized_on, :utc_datetime_usec
    field :modified_on, :utc_datetime
  end
end
