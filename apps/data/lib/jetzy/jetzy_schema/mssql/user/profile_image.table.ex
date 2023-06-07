defmodule JetzySchema.MSSQL.User.ProfileImage.Table do
  use Ecto.Schema
  @nmid_index 68

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserProfileImage")
  # ENTRY UserProfileImage JetzySchema.MSSQL.User.ProfileImage.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserProfileImage]    Script Date: 2/24/2020 10:36:40 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserProfileImage](
  [ProfileImageId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [ImageName] [nvarchar](200) NOT NULL,
  [IsCurrent] [bit] NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  CONSTRAINT [PK_ProfileImage] PRIMARY KEY CLUSTERED
  (
  [ProfileImageId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserProfileImage] ADD  DEFAULT ((0)) FOR [IsCurrent]
  GO

  ALTER TABLE [dbo].[UserProfileImage] ADD  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserProfileImage] ADD  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserProfileImage]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileImage_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserProfileImage] CHECK CONSTRAINT [FK_UserProfileImage_Users]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"ProfileImageId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserProfileImage" do
    # CREATE TABLE [dbo].[UserProfileImage](
    # field :profile_image_id, Tds.Ecto.UUID, source: :"ProfileImageId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :image_name, :string, source: :"ImageName"
    field :is_current, :boolean, source: :"IsCurrent"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
  end
end
