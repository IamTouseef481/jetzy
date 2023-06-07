defmodule JetzySchema.PG.Ledger.Reward.Redemption.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_ledger_reward_redemption)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_ledger_reward_redemption" do
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
