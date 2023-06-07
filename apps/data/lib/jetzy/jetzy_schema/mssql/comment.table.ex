defmodule JetzySchema.MSSQL.Comment.Table do
  require Logger
  use Ecto.Schema
  @nmid_index 9
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Comments")

  # ENTRY Comments JetzySchema.MSSQL.Comment.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Comments]    Script Date: 2/24/2020 9:48:21 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Comments](
  [CommentId] [bigint] IDENTITY(1,1) NOT NULL,
  [CommentSourceId] [int] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Description] [nvarchar](max) NULL,
  [ParentId] [bigint] NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [UpdatedBy] [uniqueidentifier] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [CommentId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Comments] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[Comments] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"CommentId"}
  @derive {Phoenix.Param, key: :id}
  schema "Comments" do
    # CREATE TABLE [dbo].[Comments](
    # field :comment, :integer, source: :"CommentId"
    field :comment_source, :integer, source: :"CommentSourceId"
    field :user, Tds.Ecto.UUID, source: :"UserId"
    field :description, :string, load_in_query: true, source: :"Description"
    field :parent, :integer, source: :"ParentId"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :modified_by, Tds.Ecto.UUID, source: :"UpdatedBy"
  end



  def by_identifier(identifier, context, options \\ nil) do
    by_identifier!(identifier, context, options)
  end
  def by_identifier!(identifier, _context, _options \\ nil) do
    query = from u in JetzySchema.MSSQL.Comment.Table,
                 where: u.id == ^identifier,
                 limit: 1
    case JetzySchema.MSSQL.Repo.all(query) do
      [r | _] -> r
      _ -> nil
    end
  end


  def location!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    nil
  end


  def location(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    nil
  end


  def geo!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    nil
  end


  def geo(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    nil
  end


  def comment_type!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    :text
  end

  def comment_type(%{__struct__: JetzySchema.MSSQL.Comment.Table} = _record, _context, _options) do
    :text
  end

  def status!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, _context, _options) do
    record.deleted && :deleted || :active
  end

  def status(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, _context, _options) do
    record.deleted && :deleted || :active
  end



  def time_stamp!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end



  def parent!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
    cond do
      record.comment_source == 1 -> nil
      record.comment_source == 2 ->
        p = Jetzy.Comment.Repo.by_legacy!(record.parent, context, options)
        Logger.info "GET BY PARENT! . . . #{inspect record} -> #{inspect p}\n\n\n\n\n"
        p

    end
  end


  def parent(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
    cond do
      record.comment_source == 1 -> nil
      record.comment_source == 2 ->
        p = Jetzy.Comment.Repo.by_legacy(record.parent, context, options)
        Logger.info "GET BY PARENT! . . . #{inspect record} -> #{inspect p}\n\n\n\n\n"
        p
    end
  end


  def subject!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
    cond do
      record.comment_source == 1 -> Jetzy.Post.Repo.by_legacy!(record.parent, context, options)
      record.comment_source == 2 ->
        parent = Jetzy.Comment.Repo.by_legacy!(record.parent, context, options)
                 |> Noizu.ERP.entity!()
        parent && parent.subject
    end
  end

  def subject(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
    cond do
      record.comment_source == 1 -> Jetzy.Post.Repo.by_legacy(record.parent, context, options)
      record.comment_source == 2 ->
        parent = Jetzy.Comment.Repo.by_legacy(record.parent, context, options)
                 |> Noizu.ERP.entity()
        parent && parent.subject
    end
  end

  def children!(record, context, options), do: children(record, context, options)
  def children(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, _context, _options) do
    cond do
      record.comment_source == 1 ->
        query = from c in JetzySchema.MSSQL.Comment.Table,
                     where: c.parent == ^record.id,
                     where: c.comment_source == 2
        JetzySchema.MSSQL.Repo.all(query)
      :else -> []
    end
  end

end
