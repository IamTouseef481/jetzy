defmodule JetzySchema.MSSQL.User.Moment.Table do
  use Ecto.Schema
  @nmid_index 57

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserMoments")
  # ENTRY UserMoments JetzySchema.MSSQL.User.Moment.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserMoments]    Script Date: 2/24/2020 10:31:16 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserMoments](
  [MomentId] [uniqueidentifier] NOT NULL,
  [MomentTitle] [nvarchar](100) NOT NULL,
  [MomentDescription] [nvarchar](500) NULL,
  [MomentCountry] [nvarchar](100) NULL,
  [MomentCity] [nvarchar](100) NULL,
  [MomentLocation] [nvarchar](100) NULL,
  [MomentLatitude] [nvarchar](50) NULL,
  [MomentLangitude] [nvarchar](50) NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [IsShared] [bit] NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  [IsMomentImageSync] [bit] NULL,
  [ApiVersion] [int] NULL,
  CONSTRAINT [PK_UserMoments] PRIMARY KEY CLUSTERED
  (
  [MomentId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  CONSTRAINT [DF_UserMoments_IsShared]  DEFAULT ((0)) FOR [IsShared]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  CONSTRAINT [DF_UserMoments_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  CONSTRAINT [DF_UserMoments_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  CONSTRAINT [DF_UserMoments_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  CONSTRAINT [df_UserMoments_IsMomentImageSync]  DEFAULT ((0)) FOR [IsMomentImageSync]
  GO

  ALTER TABLE [dbo].[UserMoments] ADD  DEFAULT ((0)) FOR [ApiVersion]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"MomentId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserMoments" do
    # CREATE TABLE [dbo].[UserMoments](
    # field :moment_id, Tds.Ecto.UUID, source: :"MomentId"
    field :moment_title, :string, source: :"MomentTitle"
    field :moment_description, :string, source: :"MomentDescription"
    field :moment_country, :string, source: :"MomentCountry"
    field :moment_city, :string, source: :"MomentCity"
    field :moment_location, :string, source: :"MomentLocation"
    field :latitude, :string, source: :"MomentLatitude"
    field :longitude, :string, source: :"MomentLangitude"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :is_shared, :boolean, source: :"IsShared"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :is_moment_image_sync, :boolean, source: :"IsMomentImageSync"
    field :api_version, :integer, source: :"ApiVersion"
  end
end
