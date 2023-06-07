defmodule JetzySchema.PG.Offer.Activity.Attribute.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_offer_activity_attribute)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_offer_activity_attribute" do
    field :offer_activity, JetzySchema.Types.Offer.Activity.Reference
    field :attribute, JetzySchema.Types.Business.Attribute.Type.Enum
    field :value, :integer
    field :description, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
