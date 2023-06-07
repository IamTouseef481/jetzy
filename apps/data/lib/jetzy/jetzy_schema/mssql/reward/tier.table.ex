defmodule JetzySchema.MSSQL.Reward.Tier.Table do
  use Ecto.Schema
  @nmid_index 39

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"RewardTier")
  # ENTRY RewardTier JetzySchema.MSSQL.Reward.Tier.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[RewardTier]    Script Date: 2/24/2020 10:16:16 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[RewardTier](
  [RewardTierId] [int] IDENTITY(1,1) NOT NULL,
  [TierName] [nvarchar](100) NOT NULL,
  [Description] [nvarchar](100) NULL,
  [StartPoint] [int] NOT NULL,
  [EndPoint] [int] NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifyDate] [datetime] NULL,
  [IsDeleted] [bit] NOT NULL,
  CONSTRAINT [PK_RewardTier] PRIMARY KEY CLUSTERED
  (
  [RewardTierId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[RewardTier] ADD  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[RewardTier] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"RewardTierId"}
  @derive {Phoenix.Param, key: :id}
  schema "RewardTier" do
    # CREATE TABLE [dbo].[RewardTier](
    # field :reward_tier_id, :integer, source: :"RewardTierId"
    field :tier_name, :string, source: :"TierName"
    field :description, :string, source: :"Description"
    field :start_point, :integer, source: :"StartPoint"
    field :end_point, :integer, source: :"EndPoint"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifyDate"
    field :deleted, :boolean, source: :"IsDeleted"
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Reward.Tier.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

end
