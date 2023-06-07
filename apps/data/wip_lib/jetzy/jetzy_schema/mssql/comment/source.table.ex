defmodule JetzySchema.MSSQL.Comment.Source.Table do
  use Ecto.Schema
  @nmid_index 11

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"CommentSources")
  # ENTRY CommentSources JetzySchema.MSSQL.Comment.Source.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[CommentSources]    Script Date: 2/24/2020 9:46:59 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[CommentSources](
  [CommentSourceId] [bigint] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](250) NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [CommentSourceId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[CommentSources] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[CommentSources] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"CommentSourceId"}
  @derive {Phoenix.Param, key: :id}
  schema "CommentSources" do

    # CREATE TABLE [dbo].[CommentSources](
    #field :comment_source, :integer, source: :"CommentSourceId"
    field :name, :string, source: :"Name"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"

  end
end
