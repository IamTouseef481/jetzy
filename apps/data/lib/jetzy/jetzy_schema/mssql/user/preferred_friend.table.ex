defmodule JetzySchema.MSSQL.User.PreferredFriend.Table do
  use Ecto.Schema
  @nmid_index 66

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserPreferedFriends")
  # ENTRY UserPreferedFriends JetzySchema.MSSQL.User.PreferredFriend.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserPreferedFriends]    Script Date: 2/24/2020 10:34:55 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserPreferedFriends](
  [UserPreferedFriendId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [FriendId] [uniqueidentifier] NOT NULL,
  [CreatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserPreferedFriendId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserPreferedFriends] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserPreferedFriends]  WITH CHECK ADD  CONSTRAINT [FK_UserPreferedFriend_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserPreferedFriends] CHECK CONSTRAINT [FK_UserPreferedFriend_Users]
  GO

  ALTER TABLE [dbo].[UserPreferedFriends]  WITH CHECK ADD  CONSTRAINT [FK_UserPreferedFriends_Users] FOREIGN KEY([FriendId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserPreferedFriends] CHECK CONSTRAINT [FK_UserPreferedFriends_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserPreferedFriendId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserPreferedFriends" do
    # CREATE TABLE [dbo].[UserPreferedFriends](
    # field :user_prefered_friend_id, :integer, source: :"UserPreferedFriendId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :friend_id, Tds.Ecto.UUID, source: :"FriendId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
  end
end
