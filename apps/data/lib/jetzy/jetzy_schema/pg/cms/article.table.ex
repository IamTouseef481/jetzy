defmodule JetzySchema.PG.CMS.Article.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_cms_article)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_article" do
    #  Fields and Secondary Relations
    field :owner, JetzySchema.Types.Universal.Reference
    field :article_type, JetzySchema.Types.CMS.Article.Type.Enum

    field :active_version, JetzySchema.Types.Universal.Reference
    field :active_revision, JetzySchema.Types.Universal.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
