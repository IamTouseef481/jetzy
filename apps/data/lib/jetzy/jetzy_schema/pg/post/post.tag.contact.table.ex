defmodule JetzySchema.PG.Post.Tag.Contact.Table do
  @moduledoc """
  table defined in  liquibase/1.0/007_user_context.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_post_entity_tag_contact)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_post_entity_tag_contact" do
    field :name, :string
    field :contact, :string
    field :mobile, :string
    field :status, JetzySchema.Types.Status.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
