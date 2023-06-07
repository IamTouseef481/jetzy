defmodule JetzySchema.MSSQL.Notification.Setting.Table do
  use Ecto.Schema
  @nmid_index 23

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"NotificationSettings")
  # ENTRY NotificationSettings JetzySchema.MSSQL.Notification.Setting.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[NotificationSettings]    Script Date: 2/24/2020 9:59:13 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[NotificationSettings](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [NotificationTypeId] [int] NOT NULL,
  [SendNotification] [bit] NOT NULL,
  [SendMail] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_NotificationSettings] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[NotificationSettings] ADD  CONSTRAINT [DF__Notificat__SendN__487999A9]  DEFAULT ((1)) FOR [SendNotification]
  GO

  ALTER TABLE [dbo].[NotificationSettings] ADD  CONSTRAINT [DF__Notificat__SendM__496DBDE2]  DEFAULT ((1)) FOR [SendMail]
  GO

  ALTER TABLE [dbo].[NotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK__Notificat__Notif__47857570] FOREIGN KEY([NotificationTypeId])
  REFERENCES [dbo].[NotificationTypes] ([Id])
  GO

  ALTER TABLE [dbo].[NotificationSettings] CHECK CONSTRAINT [FK__Notificat__Notif__47857570]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "NotificationSettings" do
    # CREATE TABLE [dbo].[NotificationSettings](
    #field :id, :integer
    field :user, Tds.Ecto.UUID, source: :"UserId"
    field :notification_type, :integer, source: :"NotificationTypeId"
    field :send_notification, :boolean, source: :"SendNotification"
    field :send_mail, :boolean, source: :"SendMail"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end


  def time_stamp(%{__struct__: JetzySchema.MSSQL.Notification.Setting.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end
end
