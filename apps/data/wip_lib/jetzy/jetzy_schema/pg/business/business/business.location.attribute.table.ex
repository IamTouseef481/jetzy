defmodule JetzySchema.PG.Business.Location.Attribute.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_business_location_attribute)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_business_location_attribute" do
    field :business_location, JetzySchema.Types.Business.Location.Reference

    field :attribute, JetzySchema.Types.Business.Attribute.Type.Enum
    field :value, :integer
    field :description, JetzySchema.Types.VersionedBusiness.Reference
    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
