defmodule JetzySchema.PG.Locale.Country.Enum.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.enum_table(:vnext_locale_country, [entity: Jetzy.Locale.Country.Enum.Entity])

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_locale_country" do
    field :description, JetzySchema.Types.VersionedString.Reference
    field :iso_3166_code, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end

end
