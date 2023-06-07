defmodule JetzySchema.MSSQL.Post.Type.Table do
  use Ecto.Schema
  @nmid_index 26

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"ShoutoutType")
  # ENTRY ShoutoutType JetzySchema.MSSQL.ShoutOutType.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[ShoutoutType]    Script Date: 2/24/2020 10:16:56 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[ShoutoutType](
  [ShoutoutTypeId] [int] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](200) NOT NULL,
  [SortOrder] [int] NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [Status] [int] NOT NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [ShoutoutTypeId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[ShoutoutType] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ShoutoutTypeId"}
  @derive {Phoenix.Param, key: :id}
  schema "ShoutoutType" do
    # CREATE TABLE [dbo].[ShoutoutType](
    # field :shoutout_type_id, :integer, source: :"ShoutoutTypeId"
    field :name, :string, source: :"Name"
    field :sort_order, :integer, source: :"SortOrder"
    field :deleted, :boolean, source: :"IsDeleted"
    field :status, :integer, source: :"Status"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
