defmodule JetzySchema.MSSQL.Notification.Type.Table do
  use Ecto.Schema
  @nmid_index 24

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"NotificationTypes")
  # ENTRY NotificationTypes JetzySchema.MSSQL.Notification.Type.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[NotificationTypes]    Script Date: 2/24/2020 10:00:40 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[NotificationTypes](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [Description] [varchar](200) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK__Notifica__3214EC07A2935244] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[NotificationTypes] ADD  CONSTRAINT [NotificationTypes_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[NotificationTypes] ADD  CONSTRAINT [NotificationTypes_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[NotificationTypes] ADD  CONSTRAINT [NotificationTypes_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "NotificationTypes" do
    # CREATE TABLE [dbo].[NotificationTypes](
    # field :id, :integer
    field :description, :string, source: :"Description"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
