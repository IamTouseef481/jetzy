defmodule JetzySchema.PG.User.Point.Balance.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_point_balance)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_point_balance" do
    field :user, JetzySchema.Types.Universal.Reference
    field :at_transaction, JetzySchema.Types.Universal.Reference
    field :balance, :integer

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
