defmodule JetzySchema.PG.CMS.Detail.Article.Revision.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 8
  JetzySchema.NoizuTableBehaviour.table(:vnext_cms_detail_article_revision)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_detail_article_revision" do
    #  Fields and Secondary Relations
    field :title, :string
    field :body, :string
  end
end
