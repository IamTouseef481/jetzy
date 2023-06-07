defmodule JetzySchema.PG.CMS.Article.Version.Revision.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_cms_revision)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_revision" do
    field :revision_number, :integer
    field :article, JetzySchema.Types.Universal.Reference
    field :version, JetzySchema.Types.Universal.Reference
    field :editor, JetzySchema.Types.Universal.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
