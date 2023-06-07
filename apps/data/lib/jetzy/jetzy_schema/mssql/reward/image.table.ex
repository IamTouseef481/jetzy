defmodule JetzySchema.MSSQL.Reward.Image.Table do
  use Ecto.Schema
  @nmid_index 335

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"RewardImages")
  # ENTRY RewardTier JetzySchema.MSSQL.Reward.Tier.Table

  @primary_key {:id, :id, autogenerate: true, source: :"ImageID"}
  @derive {Phoenix.Param, key: :id}
  schema "RewardImages" do
    # CREATE TABLE [dbo].[RewardTier](
    # field :reward_tier_id, :integer, source: :"RewardTierId"
    field :reward_offer_id, Tds.Ecto.UUID, source: :"RewardOfferId"
    field :image, :string, source: :"ImageName"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
