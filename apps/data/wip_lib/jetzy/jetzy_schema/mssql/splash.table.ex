defmodule JetzySchema.MSSQL.Splash.Table do
  use Ecto.Schema
  @nmid_index 40

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Splash")
  # ENTRY Splash JetzySchema.MSSQL.Splash.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Splash]    Script Date: 2/24/2020 10:18:07 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Splash](
  [SplashId] [int] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](100) NOT NULL,
  [Email] [nvarchar](100) NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifyDate] [datetime] NULL,
  [IsDeleted] [bit] NOT NULL,
  [City] [nvarchar](100) NULL,
  CONSTRAINT [PK_Splash] PRIMARY KEY CLUSTERED
  (
  [SplashId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Splash] ADD  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[Splash] ADD  DEFAULT (getdate()) FOR [LastModifyDate]
  GO

  ALTER TABLE [dbo].[Splash] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"SplashId"}
  @derive {Phoenix.Param, key: :id}
  schema "Splash" do
    # CREATE TABLE [dbo].[Splash](
    # field :splash_id, :integer, source: :"SplashId"
    field :name, :string, source: :"Name"
    field :email, :string, source: :"Email"
    field :created_date, :utc_datetime, source: :"CreatedDate"
    field :last_modify_date, :utc_datetime, source: :"LastModifyDate"
    field :deleted, :boolean, source: :"IsDeleted"
    field :city, :string, source: :"City"
  end
end
