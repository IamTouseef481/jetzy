defmodule JetzySchema.PG.Sphinx.Index.Table do
  @moduledoc """
  table defined in  liquibase/1.0/003_content.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_sphinx_index)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_sphinx_index" do
    field :description, JetzySchema.Types.VersionedString.Reference
    field :elixir_class, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
