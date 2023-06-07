defmodule JetzySchema.MSSQL.User.Follow.Table do
  use Ecto.Schema
  @nmid_index 48

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserFollow")
  # ENTRY UserFollow JetzySchema.MSSQL.User.Follow.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserFollow]    Script Date: 2/24/2020 10:23:54 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserFollow](
  [UserFriendId] [bigint] IDENTITY(1,1) NOT NULL,
  [Userid] [uniqueidentifier] NOT NULL,
  [FriendId] [uniqueidentifier] NOT NULL,
  [IsFriend] [bit] NOT NULL,
  [IsRequestSent] [bit] NOT NULL,
  [IsBlocked] [bit] NULL,
  [FriendBlocked] [bit] NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  CONSTRAINT [PK_UserFollow] PRIMARY KEY CLUSTERED
  (
  [UserFriendId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserFollow] ADD  CONSTRAINT [DF_UserFollow_IsFriend]  DEFAULT ((0)) FOR [IsFriend]
  GO

  ALTER TABLE [dbo].[UserFollow] ADD  CONSTRAINT [DF_UserFollow_IsBlocked]  DEFAULT ((0)) FOR [IsBlocked]
  GO

  ALTER TABLE [dbo].[UserFollow] ADD  CONSTRAINT [DF_UserFollow_FriendBlocked]  DEFAULT ((0)) FOR [FriendBlocked]
  GO

  ALTER TABLE [dbo].[UserFollow] ADD  CONSTRAINT [DF_UserFollow_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserFollow] ADD  CONSTRAINT [DF_UserFollow_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserFollow]  WITH CHECK ADD  CONSTRAINT [FK_UserFollow_Users] FOREIGN KEY([Userid])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserFollow] CHECK CONSTRAINT [FK_UserFollow_Users]
  GO
  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserFriendId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserFollow" do
    # CREATE TABLE [dbo].[UserFollow](
    # field :user_friend_id, :integer, source: :"UserFriendId"
    field :userid, Tds.Ecto.UUID, source: :"Userid"
    field :friend_id, Tds.Ecto.UUID, source: :"FriendId"
    field :is_friend, :boolean, source: :"IsFriend"
    field :is_request_sent, :boolean, source: :"IsRequestSent"
    field :is_blocked, :boolean, source: :"IsBlocked"
    field :friend_blocked, :boolean, source: :"FriendBlocked"
    field :created_date, :utc_datetime, source: :"CreatedDate"
    field :last_modified_date, :utc_datetime, source: :"LastModifiedDate"
  end
end
