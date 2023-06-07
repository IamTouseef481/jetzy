defmodule JetzySchema.MSSQL.User.Filter.Table do
  use Ecto.Schema
  @nmid_index 47

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserFilter")
  # ENTRY UserFilter JetzySchema.MSSQL.User.Filter.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserFilter]    Script Date: 2/24/2020 10:23:12 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserFilter](
  [UserFilterId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NULL,
  [Gender] [char](10) NULL,
  [AgeFrom] [decimal](18, 2) NOT NULL,
  [AgeTo] [decimal](18, 2) NOT NULL,
  [IsLocal] [bit] NULL,
  [IsTraveler] [bit] NOT NULL,
  [IsNotFriend] [bit] NULL,
  [IsFriend] [bit] NOT NULL,
  [Location] [nvarchar](100) NULL,
  [Distance] [int] NULL,
  [DistanceType] [char](1) NULL,
  [Interests] [nvarchar](100) NULL,
  CONSTRAINT [PK_UserFilter] PRIMARY KEY CLUSTERED
  (
  [UserFilterId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserFilter] ADD  CONSTRAINT [DF_UserFilter_IsLocal]  DEFAULT ((0)) FOR [IsLocal]
  GO

  ALTER TABLE [dbo].[UserFilter] ADD  CONSTRAINT [DF_UserFilter_IsTraveler]  DEFAULT ((0)) FOR [IsTraveler]
  GO

  ALTER TABLE [dbo].[UserFilter] ADD  CONSTRAINT [DF_UserFilter_IsNotFriend]  DEFAULT ((0)) FOR [IsNotFriend]
  GO

  ALTER TABLE [dbo].[UserFilter] ADD  CONSTRAINT [DF_UserFilter_IsFriend]  DEFAULT ((0)) FOR [IsFriend]
  GO

  ALTER TABLE [dbo].[UserFilter]  WITH CHECK ADD  CONSTRAINT [FK_UserFilter_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserFilter] CHECK CONSTRAINT [FK_UserFilter_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserFilterId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserFilter" do
    # CREATE TABLE [dbo].[UserFilter](
    # field :user_filter_id, :integer, source: :"UserFilterId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :gender, :string, source: :"Gender"
    field :age_from, :decimal, precision: 18, scale: 2, source: :"AgeFrom"
    field :age_to, :decimal, precision: 18, scale: 2, source: :"AgeTo"
    field :is_local, :boolean, source: :"IsLocal"
    field :is_traveler, :boolean, source: :"IsTraveler"
    field :is_not_friend, :boolean, source: :"IsNotFriend"
    field :is_friend, :boolean, source: :"IsFriend"
    field :location, :string, source: :"Location"
    field :distance, :integer, source: :"Distance"
    field :distance_type, :string, source: :"DistanceType"
    field :interests, :string, source: :"Interests"
  end
end
