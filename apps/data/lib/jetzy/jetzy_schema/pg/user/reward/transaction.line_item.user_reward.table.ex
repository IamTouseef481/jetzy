defmodule JetzySchema.PG.User.Reward.Transaction.LineItem.User.Reward.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:user_reward_transaction_line_item_user_reward)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "user_reward_transaction_line_item_user_reward" do

    field :user_reward, JetzySchema.Types.Universal.Reference
    field :user_reward_transaction, JetzySchema.Types.Universal.Reference
    field :user_reward_transaction_line_item, JetzySchema.Types.Universal.Reference
    field :item, JetzySchema.Types.Universal.Reference
    
    field :points, :integer
    field :discount, :integer
  end
end
