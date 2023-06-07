defmodule JetzySchema.MSSQL.User.Preference.Table do
  use Ecto.Schema
  @nmid_index 65

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPreference")
  # ENTRY UserPreference JetzySchema.MSSQL.User.Preference.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPreference]    Script Date: 2/24/2020 10:35:35 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPreference](
  [PrefrenceId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [PrefrenceType] [int] NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [PrefrenceId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserPreference] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserPreference] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserPreference]  WITH CHECK ADD  CONSTRAINT [FK_UserPreference_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserPreference] CHECK CONSTRAINT [FK_UserPreference_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"PrefrenceId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPreference" do
    # CREATE TABLE [dbo].[UserPreference](
    # field :prefrence_id, :integer, source: :"PrefrenceId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :prefrence_type, :integer, source: :"PrefrenceType"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
