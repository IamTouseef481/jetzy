defmodule JetzySchema.PG.User.Reward.Transaction.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_reward_transaction)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_reward_transaction" do
    field :user, JetzySchema.Types.Universal.Reference
    field :source, JetzySchema.Types.Universal.Reference
    field :transaction_type, JetzySchema.Types.Transaction.Type.Enum
    field :transaction_status, JetzySchema.Types.Transaction.Status.Enum

    field :points, :integer

    field :note, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
