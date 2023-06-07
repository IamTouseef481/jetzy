defmodule JetzySchema.MSSQL.User.Notification.Type.Table do
  use Ecto.Schema
  @nmid_index 61

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserNotificationsType")
  # ENTRY UserNotificationsType JetzySchema.MSSQL.User.Notification.Type.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserNotificationsType]    Script Date: 2/24/2020 10:32:27 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserNotificationsType](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [Type] [int] NOT NULL,
  [Description] [varchar](200) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK__UserNoti__3214EC07E773EA04] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserNotificationsType] ADD  CONSTRAINT [UserNotificationsType_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserNotificationsType] ADD  CONSTRAINT [UserNotificationsType_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserNotificationsType] ADD  CONSTRAINT [UserNotificationsType_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "UserNotificationsType" do

    # CREATE TABLE [dbo].[UserNotificationsType](
    # field :id, :integer
    field :type, :integer, source: :"Type"
    field :description, :string, source: :"Description"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"

  end
end
