defmodule JetzySchema.PG.CMS.Article.Version.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_cms_version)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_cms_version" do
    field :article, JetzySchema.Types.Universal.Reference
    field :editor, JetzySchema.Types.Universal.Reference
    field :status, JetzySchema.Types.Status.Enum
    field :active_revision, JetzySchema.Types.Universal.Reference

    field :parent, JetzySchema.Types.Universal.Reference
    field :depth, :integer
    field :path_a11, :integer
    field :path_a12, :integer
    field :path_a21, :integer
    field :path_a22, :integer

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
