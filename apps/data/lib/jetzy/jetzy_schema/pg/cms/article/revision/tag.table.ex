defmodule JetzySchema.PG.CMS.Article.Revision.Tag.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  @nmid_index 1
  JetzySchema.NoizuTableBehaviour.table(:vnext_cms_article_revision_tag)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_article_revision_tag" do
    #  Fields and Secondary Relations
    field :article_revision, JetzySchema.Types.Universal.Reference
    field :tag, JetzySchema.Types.Universal.Reference
    field :weight, :integer
  end
end
