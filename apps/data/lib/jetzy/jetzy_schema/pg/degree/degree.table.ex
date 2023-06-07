defmodule JetzySchema.PG.Degree.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_degree)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_degree" do
    field :name, :string
    field :description, JetzySchema.Types.VersionedString.Reference

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
