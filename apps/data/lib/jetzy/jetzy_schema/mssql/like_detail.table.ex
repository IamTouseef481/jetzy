defmodule JetzySchema.MSSQL.LikeDetail.Table do
  use Ecto.Schema
  @nmid_index 19

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"LikeDetails")
  # ENTRY LikeDetails JetzySchema.MSSQL.LikeDetail.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[LikeDetails]    Script Date: 2/24/2020 9:56:37 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[LikeDetails](
  [CommentLikeId] [bigint] IDENTITY(1,1) NOT NULL,
  [LikeSourceId] [int] NOT NULL,
  [ItemId] [bigint] NOT NULL,
  [Liked] [bit] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [oldMoment] [bit] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [CommentLikeId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[LikeDetails] ADD  DEFAULT ((0)) FOR [Liked]
  GO

  ALTER TABLE [dbo].[LikeDetails] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[LikeDetails] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[LikeDetails] ADD  DEFAULT ((0)) FOR [oldMoment]
  GO

  ALTER TABLE [dbo].[LikeDetails]  WITH CHECK ADD  CONSTRAINT [FK_LikeDetails_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[LikeDetails] CHECK CONSTRAINT [FK_LikeDetails_Users]
  GO



  """
  @primary_key {:id, :id, autogenerate: true, source: :"CommentLikeId"}
  @derive {Phoenix.Param, key: :id}
  schema "LikeDetails" do
    # CREATE TABLE [dbo].[LikeDetails](
    #field :comment_like_id, :integer, source: :"CommentLikeId"
    field :like_source_identifier, :integer, source: :"LikeSourceId"
    field :item_id, :integer, source: :"ItemId"
    field :liked, :boolean, source: :"Liked"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :old_moment, :boolean, source: :oldMoment
  end
end
