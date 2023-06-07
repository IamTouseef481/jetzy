defmodule JetzySchema.PG.School.Table do
  @moduledoc """
  table defined in  liquibase/1.0/006_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_school)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_school" do
    field :owner, JetzySchema.Types.Universal.Reference

    field :name, :string
    field :description, JetzySchema.Types.VersionedString.Reference
    field :details, JetzySchema.Types.Universal.Reference # CMS

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
