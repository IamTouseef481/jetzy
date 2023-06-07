defmodule JetzySchema.MSSQL.User.Friend.Table do
  use Ecto.Schema
  @nmid_index 49

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserFriends")
  # ENTRY UserFriends JetzySchema.MSSQL.User.Friend.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserFriends]    Script Date: 2/24/2020 10:24:57 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserFriends](
  [UserFriendId] [bigint] IDENTITY(1,1) NOT NULL,
  [Userid] [uniqueidentifier] NOT NULL,
  [FriendId] [uniqueidentifier] NOT NULL,
  [IsFriend] [bit] NOT NULL,
  [IsRequestSent] [bit] NOT NULL,
  [IsBlocked] [bit] NULL,
  [FriendBlocked] [bit] NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  CONSTRAINT [PK_UserFriends] PRIMARY KEY CLUSTERED
  (
  [UserFriendId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserFriends] ADD  CONSTRAINT [DF_UserFriends_IsFriend]  DEFAULT ((0)) FOR [IsFriend]
  GO

  ALTER TABLE [dbo].[UserFriends] ADD  CONSTRAINT [DF_UserFriends_IsBlocked]  DEFAULT ((0)) FOR [IsBlocked]
  GO

  ALTER TABLE [dbo].[UserFriends] ADD  CONSTRAINT [DF_UserFriends_FriendBlocked]  DEFAULT ((0)) FOR [FriendBlocked]
  GO

  ALTER TABLE [dbo].[UserFriends] ADD  CONSTRAINT [DF_UserFriends_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserFriends] ADD  CONSTRAINT [DF_UserFriends_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserFriends]  WITH CHECK ADD  CONSTRAINT [FK_UserFriends_Users] FOREIGN KEY([Userid])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserFriends] CHECK CONSTRAINT [FK_UserFriends_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserFriendId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserFriends" do
    # CREATE TABLE [dbo].[UserFriends](
    # field :user_friend_id, :integer, source: :"UserFriendId"
    field :user_id, Tds.Ecto.UUID, source: :"Userid"
    field :friend_id, Tds.Ecto.UUID, source: :"FriendId"
    field :is_friend, :boolean, source: :"IsFriend"
    field :is_request_sent, :boolean, source: :"IsRequestSent"
    field :is_blocked, :boolean, source: :"IsBlocked"
    field :friend_blocked, :boolean, source: :"FriendBlocked"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
  end

  def time_stamp!(%{__struct__: JetzySchema.MSSQL.User.Friend.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end



end
