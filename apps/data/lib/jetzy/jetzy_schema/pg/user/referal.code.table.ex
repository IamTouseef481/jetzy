defmodule JetzySchema.PG.User.Referral.Code.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_referral_code)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_referral_code" do
    field :user, JetzySchema.Types.Universal.Reference
    field :weight, :integer
    field :code, :string
    field :status, JetzySchema.Types.Status.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
