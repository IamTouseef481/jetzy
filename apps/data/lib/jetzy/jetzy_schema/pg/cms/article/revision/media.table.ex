defmodule JetzySchema.PG.CMS.Article.Revision.Media.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 6
  JetzySchema.NoizuTableBehaviour.table(:vnext_cms_article_revision_media)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_article_revision_media" do
    #  Fields and Secondary Relations
    field :article_revision, JetzySchema.Types.Universal.Reference
    field :media, JetzySchema.Types.Universal.Reference
    field :weight, :integer
  end
end
