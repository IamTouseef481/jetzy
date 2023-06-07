defmodule JetzySchema.PG.CMS.Article.Revision.Attribute.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 5
  JetzySchema.NoizuTableBehaviour.table(:vnext_cms_article_revision_attribute)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_article_revision_attribute" do
    #  Fields and Secondary Relations
    field :article_revision, JetzySchema.Types.Universal.Reference
    field :attribute, JetzySchema.Types.Universal.Reference
    field :value_type, JetzySchema.Types.CMS.Article.Revision.Attribute.Value.Type.Enum
    field :string_value, :string
    field :integer_value, :integer
    field :double_value, :float
  end
end
