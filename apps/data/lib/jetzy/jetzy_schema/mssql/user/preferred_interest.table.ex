defmodule JetzySchema.MSSQL.User.PreferredInterest.Table do
  use Ecto.Schema
  @nmid_index 67

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPreferedInterest")
  # ENTRY UserPreferedInterest JetzySchema.MSSQL.User.PreferredInterest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPreferedInterest]    Script Date: 2/24/2020 10:36:08 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPreferedInterest](
  [UserPreferedInterestId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [InterestId] [int] NOT NULL,
  [CreatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserPreferedInterestId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserPreferedInterest] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserPreferedInterest]  WITH CHECK ADD  CONSTRAINT [FK_UserPreferedInterest_Interest] FOREIGN KEY([InterestId])
  REFERENCES [dbo].[Interest] ([Id])
  GO

  ALTER TABLE [dbo].[UserPreferedInterest] CHECK CONSTRAINT [FK_UserPreferedInterest_Interest]
  GO

  ALTER TABLE [dbo].[UserPreferedInterest]  WITH CHECK ADD  CONSTRAINT [FK_UserPreferedInterest_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserPreferedInterest] CHECK CONSTRAINT [FK_UserPreferedInterest_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserPreferedInterestId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPreferedInterest" do
    # CREATE TABLE [dbo].[UserPreferedInterest](
    # field :user_prefered_interest_id, :integer, source: :"UserPreferedInterestId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :interest_id, :integer, source: :"InterestId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
