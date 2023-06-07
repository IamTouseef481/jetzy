defmodule JetzySchema.PG.User.Reward.Transaction.LineItem.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_reward_transaction_line_item)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_reward_transaction_line_item" do
    field :user_reward_transaction, JetzySchema.Types.Universal.Reference
    field :item, JetzySchema.Types.Universal.Reference

    field :quantity, :integer
    field :points, :integer
    field :discount, :integer
  end
end
