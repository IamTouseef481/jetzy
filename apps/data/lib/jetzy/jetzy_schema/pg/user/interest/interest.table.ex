#             <!-- Primary Key and Global Ref Indicator -->
#            <column name="identifier" type="BIGINT UNSIGNED" autoIncrement="false"><constraints nullable="false" primaryKey="true" /></column>
#
#            <!-- Primary Relations -->
#            <column name="user" type="BIGINT UNSIGNED"><constraints nullable="false"/></column>
#            <column name="interest" type="BIGINT UNSIGNED"><constraints nullable="false"/></column>
#
#            <!-- Fields and Secondary Relations -->
#            <column name="visibility" type="TINYINT UNSIGNED" defaultValueNumeric="0"><constraints nullable="false"/></column>
#
#            <!-- Standard Time Stamps -->
#            <column name="created_on" type="DATETIME" defaultValueComputed="NOW()"><constraints nullable="false"/></column>
#            <column name="modified_on" type="DATETIME" defaultValueComputed="NOW()"><constraints nullable="false"/></column>
#            <column name="deleted_on" type="DATETIME"><constraints nullable="true"/></column>

defmodule JetzySchema.PG.User.Interest.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_interest)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_interest" do
    field :user, JetzySchema.Types.Universal.Reference
    field :interest, JetzySchema.Types.Interest.Reference
    field :visibility, JetzySchema.Types.Visibility.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
