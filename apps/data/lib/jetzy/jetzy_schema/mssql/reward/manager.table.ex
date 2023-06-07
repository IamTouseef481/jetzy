defmodule JetzySchema.MSSQL.Reward.Manager.Table do
  use Ecto.Schema
  @nmid_index 37

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"RewardManager")
  # ENTRY RewardManager JetzySchema.MSSQL.Reward.Manager.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[RewardManager]    Script Date: 2/24/2020 10:14:12 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[RewardManager](
  [RewardManagerId] [uniqueidentifier] NOT NULL,
  [WinningPoint] [int] NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifyDate] [datetime] NULL,
  [Activity] [nvarchar](100) NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [ActivityType] [int] NULL,
  CONSTRAINT [PK_RewardManager] PRIMARY KEY CLUSTERED
  (
  [RewardManagerId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[RewardManager] ADD  CONSTRAINT [DF_RewardManager_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[RewardManager] ADD  CONSTRAINT [DF_RewardManager_LastModifyDate]  DEFAULT (getdate()) FOR [LastModifyDate]
  GO

  ALTER TABLE [dbo].[RewardManager] ADD  CONSTRAINT [DF_RewardManager_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"RewardManagerId"}
  @derive {Phoenix.Param, key: :id}
  schema "RewardManager" do

    # CREATE TABLE [dbo].[RewardManager](
    # field :reward_manager_id, Tds.Ecto.UUID, source: :"RewardManagerId"
    field :winning_point, :integer, source: :"WinningPoint"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifyDate"
    field :activity, :string, source: :"Activity"
    field :deleted, :boolean, source: :"IsDeleted"
    field :activity_type, :integer, source: :"ActivityType"

  end


  def time_stamp(%{__struct__: JetzySchema.MSSQL.Reward.Manager.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

end
