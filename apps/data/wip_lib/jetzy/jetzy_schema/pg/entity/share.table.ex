defmodule JetzySchema.PG.Entity.Share.Table do
  @moduledoc """
  table defined in  liquibase/1.0/007_user_content.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_share)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_share" do
    field :status, JetzySchema.Types.Status.Enum
    field :subject, JetzySchema.Types.Universal.Reference
    field :share_type, JetzySchema.Types.Share.Type.Enum
    field :share_with, JetzySchema.Types.Universal.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
