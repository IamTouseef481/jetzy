defmodule JetzySchema.MSSQL.User.Session.Table do
  use Ecto.Schema
  @nmid_index 72

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserSession")
  # ENTRY UserSession JetzySchema.MSSQL.User.Session.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserSession]    Script Date: 2/24/2020 10:43:59 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserSession](
  [SessionId] [varchar](100) NOT NULL,
  [UserId] [varchar](50) NOT NULL,
  [DeviceId] [varchar](500) NULL,
  [LastAccessDate] [datetime] NOT NULL,
  [IsActive] [bit] NOT NULL,
  CONSTRAINT [PK_UserSession] PRIMARY KEY CLUSTERED
  (
  [SessionId] ASC,
  [UserId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserSession] ADD  CONSTRAINT [DF_UserSession_SessionId]  DEFAULT ('') FOR [SessionId]
  GO

  ALTER TABLE [dbo].[UserSession] ADD  CONSTRAINT [DF_UserSession_UserId]  DEFAULT ('') FOR [UserId]
  GO

  ALTER TABLE [dbo].[UserSession] ADD  CONSTRAINT [DF_UserSession_DeviceId]  DEFAULT ('') FOR [DeviceId]
  GO

  ALTER TABLE [dbo].[UserSession] ADD  CONSTRAINT [DF_UserSession_LastAccessDate]  DEFAULT (getdate()) FOR [LastAccessDate]
  GO

  ALTER TABLE [dbo].[UserSession] ADD  CONSTRAINT [DF_UserSession_IsActive]  DEFAULT ((0)) FOR [IsActive]
  GO
  """

  # This is awful schema string primary keys.
  @primary_key false
  schema "UserSession" do
    # CREATE TABLE [dbo].[UserSession](
    field :session_id, :string, primary_key: true, source: :"SessionId"
    field :user_id, :string, primary_key: true, source: :"UserId"
    field :device_id, :string, source: :"DeviceId"
    field :last_access_date, :utc_datetime, source: :"LastAccessDate"
    field :is_active, :boolean, source: :"IsActive"
  end
end
