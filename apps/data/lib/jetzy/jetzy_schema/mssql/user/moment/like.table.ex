defmodule JetzySchema.MSSQL.User.Moment.Like.Table do
  use Ecto.Schema
  @nmid_index 59

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserMomentLike")
  # ENTRY UserMomentLike JetzySchema.MSSQL.User.Moment.Like.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserMomentLike]    Script Date: 2/24/2020 10:30:46 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserMomentLike](
  [MomentLikeId] [bigint] IDENTITY(1,1) NOT NULL,
  [MomentId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Liked] [bit] NOT NULL,
  [CreatedDate] [datetime] NULL,
  CONSTRAINT [PK_UserMomentLike] PRIMARY KEY CLUSTERED
  (
  [MomentLikeId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserMomentLike] ADD  CONSTRAINT [DF_UserMomentLike_Liked]  DEFAULT ((0)) FOR [Liked]
  GO

  ALTER TABLE [dbo].[UserMomentLike] ADD  DEFAULT (getdate()) FOR [CreatedDate]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"MomentLikeId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserMomentLike" do
    # CREATE TABLE [dbo].[UserMomentLike](
    # field :moment_like_id, :integer, source: :"MomentLikeId"
    field :moment_id, Tds.Ecto.UUID, source: :"MomentId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :liked, :boolean, source: :"Liked"
    field :created_on, :utc_datetime, source: :"CreatedDate"
  end
end
