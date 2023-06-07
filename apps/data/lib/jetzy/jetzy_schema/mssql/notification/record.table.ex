defmodule JetzySchema.MSSQL.Notification.Record.Table do
  use Ecto.Schema
  @nmid_index 22

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"NotificationsRecord")
  # ENTRY NotificationsRecord JetzySchema.MSSQL.Notification.Record.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[NotificationsRecord]    Script Date: 2/24/2020 10:01:22 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[NotificationsRecord](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [SenderId] [uniqueidentifier] NOT NULL,
  [ReceiverId] [uniqueidentifier] NOT NULL,
  [Description] [varchar](200) NULL,
  [Type] [varchar](200) NULL,
  [FriendActivityType] [varchar](200) NULL,
  [PendingFriendRequest] [varchar](200) NULL,
  [ChatMessageType] [varchar](200) NULL,
  [MomentMessageType] [varchar](200) NULL,
  [MomentId] [varchar](200) NULL,
  [ShoutoutId] [varchar](200) NULL,
  [CommentId] [varchar](200) NULL,
  [CommentSourceId] [varchar](200) NULL,
  [GroupId] [varchar](200) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK__Notifica__3214EC0758EB4E48] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[NotificationsRecord] ADD  CONSTRAINT [NotificationsRecord_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[NotificationsRecord] ADD  CONSTRAINT [NotificationsRecord_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[NotificationsRecord] ADD  CONSTRAINT [NotificationsRecord_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "NotificationsRecord" do
    # CREATE TABLE [dbo].[NotificationsRecord](
    #field :id, :integer
    field :sender_id, Tds.Ecto.UUID, source: :"SenderId"
    field :receiver_id, Tds.Ecto.UUID, source: :"ReceiverId"
    field :description, :string, source: :"Description"
    field :type, :string, source: :"Type"
    field :friend_activity_type, :string, source: :"FriendActivityType"
    field :pending_friend_request, :string, source: :"PendingFriendRequest"
    field :chat_message_type, :string, source: :"ChatMessageType"
    field :moment_message_type, :string, source: :"MomentMessageType"
    field :moment_id, :string, source: :"MomentId"
    field :shoutout_id, :string, source: :"ShoutoutId"
    field :comment_id, :string, source: :"CommentId"
    field :comment_source, :string, source: :"CommentSourceId"
    field :group_id, :string, source: :"GroupId"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Notification.Record.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end


end
