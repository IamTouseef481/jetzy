defmodule JetzySchema.MSSQL.User.PushToken.Table do
  use Ecto.Schema
  @nmid_index 69

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPushToken")

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPushToken]    Script Date: 2/24/2020 10:37:55 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPushToken](
  [UserPushTokenId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [DeviceId] [nvarchar](50) NOT NULL,
  [PushToken] [nvarchar](500) NULL,
  [DeviceType] [char](2) NULL,
  [Language] [char](2) NULL,
  [UpdatedOn] [datetime] NULL,
  [CreatedOn] [datetime] NULL,
  CONSTRAINT [PK_UserPushToken] PRIMARY KEY CLUSTERED
  (
  [UserPushTokenId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserPushToken] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[UserPushToken] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO
  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserPushTokenId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPushToken" do
    # CREATE TABLE [dbo].[UserPushToken](
    # field :user_push_token_id, :integer, source: :"UserPushTokenId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :device_id, :string, source: :"DeviceId"
    field :push_token, :string, source: :"PushToken"
    field :device_type, :string, source: :"DeviceType"
    field :language, :string, source: :"Language"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
