defmodule JetzySchema.MSSQL.User.Notification.Record.Table do
  use Ecto.Schema
  @nmid_index 60

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UsersNotificationsRecords")
  # ENTRY UsersNotificationsRecords JetzySchema.MSSQL.User.Notification.Record.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UsersNotificationsRecords]    Script Date: 2/24/2020 10:49:04 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UsersNotificationsRecords](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Type] [int] NOT NULL,
  [IsEnable] [bit] NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK__UsersNot__3214EC07E120CD72] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UsersNotificationsRecords] ADD  CONSTRAINT [UsersNotificationsRecords_isenable]  DEFAULT ((1)) FOR [IsEnable]
  GO

  ALTER TABLE [dbo].[UsersNotificationsRecords] ADD  CONSTRAINT [UsersNotificationsRecords_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UsersNotificationsRecords] ADD  CONSTRAINT [UsersNotificationsRecords_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UsersNotificationsRecords] ADD  CONSTRAINT [UsersNotificationsRecords_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "UsersNotificationsRecords" do
    # CREATE TABLE [dbo].[UsersNotificationsRecords](
    # field :id, :integer
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :type, :integer, source: :"Type"
    field :is_enable, :boolean, source: :"IsEnable"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
