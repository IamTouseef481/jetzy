defmodule JetzySchema.MSSQL.PushNotificationLog.Table do
  use Ecto.Schema
  @nmid_index 32

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"PushNotificationLog")
  # ENTRY PushNotificationLog JetzySchema.MSSQL.PushNotificationLog.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[PushNotificationLog]    Script Date: 2/24/2020 10:02:45 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[PushNotificationLog](
  [NotificationLogId] [uniqueidentifier] NOT NULL,
  [SenderId] [uniqueidentifier] NOT NULL,
  [ReceiverId] [uniqueidentifier] NOT NULL,
  [PushType] [int] NOT NULL,
  [PushMessage] [nvarchar](max) NULL,
  [PushToken] [nvarchar](500) NULL,
  [DeviceId] [nvarchar](50) NULL,
  [DeviceType] [int] NULL,
  [ApiVersion] [int] NULL,
  [AppVersion] [nvarchar](50) NULL,
  [CreatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [NotificationLogId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[PushNotificationLog] ADD  DEFAULT (newid()) FOR [NotificationLogId]
  GO

  ALTER TABLE [dbo].[PushNotificationLog] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"NotificationLogId"}
  @derive {Phoenix.Param, key: :id}
  schema "PushNotificationLog" do
    # CREATE TABLE [dbo].[PushNotificationLog](
    # field :notification_log_id, Tds.Ecto.UUID, source: :"NotificationLogId"
    field :sender_id, Tds.Ecto.UUID, source: :"SenderId"
    field :receiver_id, Tds.Ecto.UUID, source: :"ReceiverId"
    field :push_type, :integer, source: :"PushType"
    field :push_message, :string, source: :"PushMessage"
    field :push_token, :string, source: :"PushToken"
    field :device_id, :string, source: :"DeviceId"
    field :device_type, :integer, source: :"DeviceType"
    field :api_version, :integer, source: :"ApiVersion"
    field :app_version, :string, source: :"AppVersion"
    field :created_on, :utc_datetime, source: :"CreatedOn"

  end
end
