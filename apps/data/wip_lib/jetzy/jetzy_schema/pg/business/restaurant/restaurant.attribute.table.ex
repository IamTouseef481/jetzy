defmodule JetzySchema.PG.Business.Restaurant.Attribute.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_restaurant_attribute)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_restaurant_attribute" do
    field :restaurant, JetzySchema.Types.Business.Restaurant.Reference

    field :attribute, JetzySchema.Types.Business.Attribute.Type.Enum
    field :value, :integer
    field :description, JetzySchema.Types.VersionedBusiness.Reference
    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
