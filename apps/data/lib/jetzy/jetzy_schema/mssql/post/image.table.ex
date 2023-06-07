defmodule JetzySchema.MSSQL.Post.Image.Table do
  use Ecto.Schema
  @nmid_index 27

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserShoutoutsImages")
  # ENTRY UserShoutoutsImages JetzySchema.MSSQL.User.ShoutOut.Image.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserShoutoutsImages]    Script Date: 2/24/2020 10:46:58 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserShoutoutsImages](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [ShoutoutId] [bigint] NOT NULL,
  [ShoutoutImages] [nvarchar](200) NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserShoutoutsImages] ADD  CONSTRAINT [UserShoutoutsImages_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserShoutoutsImages] ADD  CONSTRAINT [UserShoutoutsImages_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "UserShoutoutsImages" do
    # CREATE TABLE [dbo].[UserShoutoutsImages](
    # field :id, :integer
    field :post_id, :integer, source: :"ShoutoutId"
    field :post_images, :string, source: :"ShoutoutImages"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"ModifiedOn"
  end
end
