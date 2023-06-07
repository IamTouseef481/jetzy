defmodule JetzySchema.MSSQL.User.Interest.Table do
  use Ecto.Schema
  @nmid_index 54

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserInterest")
  # ENTRY UserInterest JetzySchema.MSSQL.User.Interest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserInterest]    Script Date: 2/24/2020 10:29:00 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserInterest](
  [UserInterestId] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
  [Userid] [uniqueidentifier] NOT NULL,
  [InterestId] [int] NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  [IsAdmin] [bit] NOT NULL,
  [IsActive] [int] NOT NULL,
  CONSTRAINT [PK_UserIntrest] PRIMARY KEY CLUSTERED
  (
  [UserInterestId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserInterest] ADD  CONSTRAINT [DF_UserInterest_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserInterest] ADD  CONSTRAINT [DF_UserInterest_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserInterest] ADD  DEFAULT ((0)) FOR [IsAdmin]
  GO

  ALTER TABLE [dbo].[UserInterest] ADD  DEFAULT ((1)) FOR [IsActive]
  GO

  ALTER TABLE [dbo].[UserInterest]  WITH CHECK ADD  CONSTRAINT [FK_UserInterest_Users] FOREIGN KEY([Userid])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserInterest] CHECK CONSTRAINT [FK_UserInterest_Users]
  GO



  """

  @primary_key {:id, :decimal, autogenerate: false, source: :"UserInterestId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserInterest" do
    # CREATE TABLE [dbo].[UserInterest](
    # field :user_interest_id, :decimal, precision: 18, source: :"UserInterestId"
    field :user_id, Tds.Ecto.UUID, source: :"Userid"
    field :interest_id, :integer, source: :"InterestId"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :is_admin, :boolean, source: :"IsAdmin"
    field :is_active, :integer, source: :"IsActive"
  end

  def by_legacy(guid, _context, _options \\ []) do
    JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.User.Interest.Table, guid)
  end
  def by_legacy!(guid, _context, _options \\ []) do
    JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.User.Interest.Table, guid)
  end

  def interest(record, context, options) do
    Jetzy.Interest.Repo.by_legacy(record.interest_id, context, options)
  end

  def interest!(record, context, options) do
    Jetzy.Interest.Repo.by_legacy!(record.interest_id, context, options)
  end


end
