defmodule JetzySchema.MSSQL.User.CommentTagged.Table do
  use Ecto.Schema
  @nmid_index 44

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserCommentTagged")
  # ENTRY UserCommentTagged JetzySchema.MSSQL.User.CommentTagged.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserCommentTagged]    Script Date: 2/24/2020 10:21:29 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserCommentTagged](
  [TaggedId] [int] IDENTITY(1,1) NOT NULL,
  [ParentId] [bigint] NOT NULL,
  [CommentSourceId] [int] NOT NULL,
  [Name] [uniqueidentifier] NULL,
  [Email] [varchar](100) NULL,
  [ContactNumber] [varchar](50) NULL,
  [Flag] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [TaggedId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserCommentTagged] ADD  CONSTRAINT [UserCommentTagged_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserCommentTagged] ADD  CONSTRAINT [UserCommentTagged_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"TaggedId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserCommentTagged" do
    # CREATE TABLE [dbo].[UserCommentTagged](
    # field :tagged_id, :integer, source: :"TaggedId"
    field :parent_id, :integer, source: :"ParentId"
    field :comment_source, :integer, source: :"CommentSourceId"
    field :name, Tds.Ecto.UUID, source: :"Name"
    field :email, :string, source: :"Email"
    field :contact_number, :string, source: :"ContactNumber"
    field :flag, :integer, source: :"Flag"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"ModifiedOn"
  end
end
