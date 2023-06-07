defmodule JetzySchema.PG.Ledger.User.Reward.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_ledger_user_reward)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_ledger_user_reward" do
    field :user, JetzySchema.Types.Universal.Reference
    field :item, JetzySchema.Types.Universal.Reference
    field :transaction, JetzySchema.Types.Universal.Reference

    field :credit, :integer
    field :debit, :integer

    field :note, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
