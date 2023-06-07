defmodule JetzySchema.PG.Business.Location.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_business_location)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_business_location" do
    field :business, JetzySchema.Types.Business.Reference
    field :location, JetzySchema.Types.Universal.Reference
    field :description, JetzySchema.Types.VersionedBusiness.Reference
    field :details, :integer # CMS - need to update to V3 Entity types

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
