defmodule JetzySchema.MSSQL.Post.Private.Table do
  use Ecto.Schema
  @nmid_index 29

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserShoutoutsPrivate")
  # ENTRY UserShoutoutsPrivate JetzySchema.MSSQL.User.ShoutOut.Private.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserShoutoutsPrivate]    Script Date: 2/24/2020 10:47:27 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserShoutoutsPrivate](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [ShoutoutId] [bigint] NOT NULL,
  [IsPrivate] [bit] NOT NULL,
  [GroupId] [int] NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserShoutoutsPrivate] ADD  DEFAULT ((0)) FOR [IsPrivate]
  GO

  ALTER TABLE [dbo].[UserShoutoutsPrivate] ADD  CONSTRAINT [UserShoutoutsPrivate_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserShoutoutsPrivate] ADD  CONSTRAINT [UserShoutoutsPrivate_modified_on]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO

  ALTER TABLE [dbo].[UserShoutoutsPrivate]  WITH CHECK ADD  CONSTRAINT [FK_UserShoutoutsPrivate] FOREIGN KEY([ShoutoutId])
  REFERENCES [dbo].[UserShoutouts] ([ShoutoutId])
  GO

  ALTER TABLE [dbo].[UserShoutoutsPrivate] CHECK CONSTRAINT [FK_UserShoutoutsPrivate]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"Id"}
  @derive {Phoenix.Param, key: :id}
  schema "UserShoutoutsPrivate" do
    # CREATE TABLE [dbo].[UserShoutoutsPrivate](
    #field :id, :integer
    field :post_id, :integer, source: :"ShoutoutId"
    field :private, :boolean, source: :"IsPrivate"
    field :group_id, :integer, source: :"GroupId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"ModifiedOn"
  end


  def time_stamp!(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, context, options), do: time_stamp(record, context, options)
  def time_stamp(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end

  def share_type!(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, context, options), do: share_type(record, context, options)
  def share_type(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, _context, _options) do
    cond do
      record.group_id && record.private -> :group
      record.group_id -> :group
      :else -> :public
    end
  end

  def share_with(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, context, options) do
    cond do
      record.group_id -> Jetzy.Group.Repo.by_legacy(record.group_id, context, options)
      :else -> nil
    end
  end

  def share_with!(%{__struct__: JetzySchema.MSSQL.Post.Private.Table} = record, context, options) do
    cond do
      record.group_id -> Jetzy.Group.Repo.by_legacy!(record.group_id, context, options)
      :else -> nil
    end
  end


end
