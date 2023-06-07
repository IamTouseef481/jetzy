defmodule JetzySchema.MSSQL.User.Reward.Transaction.Table do
  use Ecto.Schema
  @nmid_index 71

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserRewardTransaction")
  # ENTRY UserRewardTransaction JetzySchema.MSSQL.User.RewardTransaction.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserRewardTransaction]    Script Date: 2/24/2020 10:41:40 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserRewardTransaction](
  [UserRewardId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [RewardId] [uniqueidentifier] NOT NULL,
  [Point] [numeric](18, 0) NOT NULL,
  [BalancePoint] [numeric](18, 0) NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifiedDate] [datetime] NULL,
  [IsCompleted] [bit] NOT NULL,
  [IsCanceled] [bit] NOT NULL,
  [Remarks] [varchar](500) NULL,
  CONSTRAINT [PK_UserRewardTransaction] PRIMARY KEY CLUSTERED
  (
  [UserRewardId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserRewardTransaction] ADD  CONSTRAINT [DF_UserRewardTransaction_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserRewardTransaction] ADD  CONSTRAINT [DF_UserRewardTransaction_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserRewardTransaction] ADD  CONSTRAINT [DF_UserRewardTransaction_IsCompleted]  DEFAULT ((0)) FOR [IsCompleted]
  GO

  ALTER TABLE [dbo].[UserRewardTransaction] ADD  CONSTRAINT [DF_UserRewardTransaction_IsCanceled]  DEFAULT ((0)) FOR [IsCanceled]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserRewardId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserRewardTransaction" do
    # CREATE TABLE [dbo].[UserRewardTransaction](
    # field :user_reward_id, :integer, source: :"UserRewardId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :reward_id, Tds.Ecto.UUID, source: :"RewardId"
    field :point, :decimal, precision: 18, source: :"Point"
    field :balance_point, :decimal, precision: 18, source: :"BalancePoint"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :is_completed, :boolean, source: :"IsCompleted"
    field :is_cancelled, :boolean, source: :"IsCanceled"
    field :remarks, :string, source: :"Remarks"
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.User.Reward.Transaction.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end

end
