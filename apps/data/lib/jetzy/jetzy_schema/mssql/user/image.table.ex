defmodule JetzySchema.MSSQL.User.Image.Table do
  use Ecto.Schema
  @nmid_index 52

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserImages")
  # ENTRY UserImages JetzySchema.MSSQL.User.Image.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserImages]    Script Date: 2/24/2020 10:28:01 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserImages](
  [UserImageId] [int] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Images] [nvarchar](200) NULL,
  [OrderNumber] [int] NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserImageId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserImages] ADD  CONSTRAINT [UserImages_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserImages] ADD  CONSTRAINT [UserImages_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserImages] ADD  CONSTRAINT [UserImages_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserImageId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserImages" do
    # CREATE TABLE [dbo].[UserImages](
    # field :user_image_id, :integer, source: :"UserImageId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :image_name, :string, source: :"Images"
    field :order_number, :integer, source: :"OrderNumber"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
