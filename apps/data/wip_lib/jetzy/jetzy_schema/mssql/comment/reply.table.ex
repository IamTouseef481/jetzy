defmodule JetzySchema.MSSQL.Comment.Reply.Table do
  use Ecto.Schema
  @nmid_index 10

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"CommentReplies")
  # ENTRY CommentReplies JetzySchema.MSSQL.Comment.Reply.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[CommentReplies]    Script Date: 2/24/2020 9:45:27 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[CommentReplies](
  [CommentReplyId] [bigint] IDENTITY(1,1) NOT NULL,
  [ParentCommentId] [bigint] NOT NULL,
  [ChildCommentId] [bigint] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [CommentReplyId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[CommentReplies] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[CommentReplies] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"CommentReplyId"}
  @derive {Phoenix.Param, key: :id}
  schema "CommentReplies" do
    # CREATE TABLE [dbo].[CommentReplies](
    #field :comment_reply_id, :integer, source: :"CommentReplyId"
    field :parent_comment_id, :integer, source: :"ParentCommentId"
    field :child_comment_id, :integer, source: :"ChildCommentId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
