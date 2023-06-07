defmodule JetzySchema.PG.Business.RelevantAttribute.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 2
  JetzySchema.NoizuTableBehaviour.table(:vnext_business_activity_event_relevant_attribute)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_business_activity_event_relevant_attribute" do
    field :type, JetzySchema.Types.Business.Type.Enum
    field :attribute, JetzySchema.Types.Business.Attribute.Type.Enum
    field :weight, :integer

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end

