defmodule JetzySchema.PG.CMS.Article.Revision.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 4
  JetzySchema.NoizuTableBehaviour.table(:vnext_cms_article_revision)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_article_revision" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference

    field :article, JetzySchema.Types.Universal.Reference
    field :version, JetzySchema.Types.Universal.Reference
    field :revision, JetzySchema.Types.Universal.Reference

    field :article_name, :string
    field :article_description, :string
    field :article_note, :string
    field :article_type, JetzySchema.Types.CMS.Article.Type.Enum

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
