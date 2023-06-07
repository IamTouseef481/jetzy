defmodule JetzySchema.MSSQL.User.Moment.Image.Table do
  use Ecto.Schema
  @nmid_index 58

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserMomentsImages")
  # ENTRY UserMomentsImages JetzySchema.MSSQL.User.Moment.Image.Table


  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserMomentsImages]    Script Date: 2/24/2020 10:31:48 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserMomentsImages](
  [UserMomentsImageId] [bigint] IDENTITY(1,1) NOT NULL,
  [MomentId] [uniqueidentifier] NOT NULL,
  [ThumbImageName] [nvarchar](200) NULL,
  [SmallImageName] [nvarchar](200) NULL,
  [MediumImageName] [nvarchar](200) NULL,
  [LargeImageName] [nvarchar](200) NULL,
  [CompressedImageName] [nvarchar](200) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  [IsImageSync] [bit] NULL,
  [IsCurrent] [bit] NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserMomentsImageId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserMomentsImages] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserMomentsImages] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserMomentsImages] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[UserMomentsImages] ADD  DEFAULT ((0)) FOR [IsImageSync]
  GO

  ALTER TABLE [dbo].[UserMomentsImages] ADD  DEFAULT ((0)) FOR [IsCurrent]
  GO

  ALTER TABLE [dbo].[UserMomentsImages]  WITH CHECK ADD  CONSTRAINT [FK_UserMomentsImages_UserMoments] FOREIGN KEY([MomentId])
  REFERENCES [dbo].[UserMoments] ([MomentId])
  GO

  ALTER TABLE [dbo].[UserMomentsImages] CHECK CONSTRAINT [FK_UserMomentsImages_UserMoments]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserMomentsImageId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserMomentsImages" do
    # CREATE TABLE [dbo].[UserMomentsImages](
    # field :user_moments_image_id, :integer, source: :"UserMomentsImageId"
    field :moment_id, Tds.Ecto.UUID, source: :"MomentId"
    field :thumb_image_name, :string, source: :"ThumbImageName"
    field :small_image_name, :string, source: :"SmallImageName"
    field :medium_image_name, :string, source: :"MediumImageName"
    field :large_image_name, :string, source: :"LargeImageName"
    field :compressed_image_name, :string, source: :"CompressedImageName"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :is_image_sync, :boolean, source: :"IsImageSync"
    field :is_current, :boolean, source: :"IsCurrent"
  end
end
