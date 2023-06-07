defmodule JetzySchema.MSSQL.User.Post.Type.Table do
  use Ecto.Schema
  @nmid_index 64

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPostType")
  # ENTRY UserPostType JetzySchema.MSSQL.User.PostType.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPostType]    Script Date: 2/24/2020 10:34:20 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPostType](
  [PostTypeId] [int] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](200) NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserPostType] ADD  CONSTRAINT [UserPostType_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserPostType] ADD  CONSTRAINT [UserPostType_modified_on]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"PostTypeId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPostType" do
    # CREATE TABLE [dbo].[UserPostType](
    # field :post_type_id, :integer, source: :"PostTypeId"
    field :name, :string, source: :"Name"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
