defmodule JetzySchema.PG.User.Reward.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_reward)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_reward" do
    field :user, JetzySchema.Types.Universal.Reference
    field :item, JetzySchema.Types.Universal.Reference
    field :expires_on, :utc_datetime
    field :token, JetzySchema.Types.Universal.Reference

    field :points, :integer
    field :discount, :integer

    field :status, JetzySchema.Types.Status.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
