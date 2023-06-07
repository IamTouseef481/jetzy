defmodule JetzySchema.MSSQL.User.PointBalance.Table do
  use Ecto.Schema
  @nmid_index 63

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPointBalance")
  # ENTRY UserPointBalance JetzySchema.MSSQL.User.PointBalance.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPointBalance]    Script Date: 2/24/2020 10:33:47 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPointBalance](
  [BalanceId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [TotalPoint] [numeric](18, 0) NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifieddate] [datetime] NOT NULL,
  CONSTRAINT [PK_UserPointBalance] PRIMARY KEY CLUSTERED
  (
  [BalanceId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"BalanceId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPointBalance" do
    # CREATE TABLE [dbo].[UserPointBalance](
    # field :BalanceId, :integer, source: :"BalanceId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :total_point, :decimal, precision: 18, source: :"TotalPoint"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifieddate"
  end
end
