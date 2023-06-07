defmodule JetzySchema.PG.Post.Tag.Table do
  @moduledoc """
  table defined in  liquibase/1.0/007_user_context.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_post_entity_tag)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_post_entity_tag" do
    field :post, JetzySchema.Types.Universal.Reference
    field :tagged, JetzySchema.Types.Universal.Reference
    field :contact, JetzySchema.Types.Universal.Reference
    field :tagged_by, JetzySchema.Types.Universal.Reference
    field :blocked_by, JetzySchema.Types.Universal.Reference

    field :status, JetzySchema.Types.Status.Enum
    field :tag_type, JetzySchema.Types.Tag.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
