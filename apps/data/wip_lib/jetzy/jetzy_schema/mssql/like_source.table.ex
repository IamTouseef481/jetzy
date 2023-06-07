defmodule JetzySchema.MSSQL.LikeSource.Table do
  use Ecto.Schema
  @nmid_index 20

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"LikeSources")
  # ENTRY LikeSources JetzySchema.MSSQL.LikeSource.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[LikeSources]    Script Date: 2/24/2020 9:57:11 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[LikeSources](
  [LikeSourceId] [bigint] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](250) NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [LikeSourceId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[LikeSources] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[LikeSources] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"LikeSourceId"}
  @derive {Phoenix.Param, key: :id}
  schema "LikeSources" do
    # CREATE TABLE [dbo].[LikeSources](
    #field :like_source_identifier, :integer, source: :"LikeSourceId"
    field :name, :string, source: :"Name"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
