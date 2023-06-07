defmodule JetzySchema.MSSQL.Post.Table do
  use Ecto.Schema
  @nmid_index 25
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserShoutouts")

  # ENTRY UserShoutouts JetzySchema.MSSQL.Post.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserShoutouts]    Script Date: 2/24/2020 10:46:19 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserShoutouts](
  [ShoutoutId] [bigint] IDENTITY(1,1) NOT NULL,
  [ShoutoutGuid] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [ShoutoutTypeId] [int] NULL,
  [Title] [nvarchar](100) NULL,
  [Description] [nvarchar](max) NULL,
  [Latitude] [float] NULL,
  [Longitude] [float] NULL,
  [ImageName] [nvarchar](200) NULL,
  [ImageExtn] [nvarchar](10) NULL,
  [IsShared] [bit] NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  [IsImageSync] [bit] NULL,
  [UpdatedBy] [uniqueidentifier] NULL,
  [PostTypeId] [int] NULL,
  [oldMoment] [bit] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [ShoutoutId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT (newid()) FOR [ShoutoutGuid]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT ((0)) FOR [IsShared]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT ((0)) FOR [IsImageSync]
  GO

  ALTER TABLE [dbo].[UserShoutouts] ADD  DEFAULT ((0)) FOR [oldMoment]
  GO

  ALTER TABLE [dbo].[UserShoutouts]  WITH CHECK ADD  CONSTRAINT [FK_UserShoutouts_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserShoutouts] CHECK CONSTRAINT [FK_UserShoutouts_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ShoutoutId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserShoutouts" do
    # CREATE TABLE [dbo].[UserShoutouts](
    #field :shoutout, :integer, source: :"ShoutoutId"
    field :guid, Tds.Ecto.UUID, source: :"ShoutoutGuid"
    field :user, Tds.Ecto.UUID, source: :"UserId"
    field :post_topic, JetzySchema.Types.Post.Topic.Enum, source: :"ShoutoutTypeId"
    field :title, :string, source: :"Title"
    field :description, :string, load_in_query: true, source: :"Description"
    field :latitude, :decimal, source: :"Latitude"
    field :longitude, :decimal, source: :"Longitude"
    field :image_name, :string, source: :"ImageName"
    field :image_extension, :string, source: :"ImageExtn"
    field :is_shared, :boolean, source: :"IsShared"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :is_image_sync, :boolean, source: :"IsImageSync"
    field :modified_by, Tds.Ecto.UUID, source: :"UpdatedBy"
    field :post_type, JetzySchema.Types.Post.Type.Enum, source: :"PostTypeId"
    field :old_moment, :boolean, source: :oldMoment
  end




  def comments(record, _context, _options) do
    post_id = record.id
    query = from c in JetzySchema.MSSQL.Comment.Table,
                 where: c.parent == ^post_id,
                 where: c.comment_source == 1
    JetzySchema.MSSQL.Repo.all(query)
  end

  def reactions(record, _context, _options) do
    post_id = record.id
    query = from c in JetzySchema.MSSQL.LikeDetail.Table,
                 where: c.item_id == ^post_id
    JetzySchema.MSSQL.Repo.all(query)
  end

  def location!(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    query = from p in JetzySchema.MSSQL.Address.Post.Mapping.Table,
                 where: p.post_id == ^record.id,
                 select: p
    case  JetzySchema.MSSQL.Repo.all(query) do
      [h|_] -> h
      _ -> nil
    end
  end
  def location!(%{__struct__: _} = _record, _context, _options) do
    nil
  end

  def location(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    query = from p in JetzySchema.MSSQL.Address.Post.Mapping.Table,
                 where: p.post_id == ^record.id,
                 select: p
    case  JetzySchema.MSSQL.Repo.all(query) do
      [h|_] -> h
      _ -> nil
    end
  end
  def location(%{__struct__: _} = _record, _context, _options) do
    nil
  end

  def interests(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    query = from p in JetzySchema.MSSQL.Post.Interest.Table,
                 where: p.post_id == ^record.id,
                 select: p
    case  JetzySchema.MSSQL.Repo.all(query) do
      v when is_list(v) -> v
      _ -> []
    end
  end

  def tags(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    query = from p in JetzySchema.MSSQL.Post.Tagged.Table,
                 where: p.post_id == ^record.id,
                 select: p
    case  JetzySchema.MSSQL.Repo.all(query) do
      v when is_list(v) -> v
      _ -> []
    end
  end

  def topic(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    record.post_topic
  end

  def media(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    cond do
      is_bitstring(record.image_name) ->
        guid = String.trim(record.image_name)
        extension = record.image_extension && String.trim(record.image_extension) || "jpg"
        guid && "https://api.jetzyapp.com/Images/ShoutoutImage/#{record.user}/#{guid}.#{extension}"
      :else -> nil
    end
  end

  def media_type(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    cond do
      record.image_name -> :image
      :else -> :text
    end
  end

  def type(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    record.post_type || :post
  end

  def status(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    record.deleted && :deleted || :active
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end


  def sharing(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, _context, _options) do
    query = from p in JetzySchema.MSSQL.Post.Private.Table,
                 where: p.post_id == ^record.id,
                 select: p
    case  JetzySchema.MSSQL.Repo.all(query) do
      v when is_list(v) -> v
      _ -> []
    end
  end


  def by_identifier(identifier, context, options \\ nil) do
    by_identifier!(identifier, context, options)
  end
  def by_identifier!(identifier, _context, _options \\ nil) do
    query = from u in JetzySchema.MSSQL.Post.Table,
                 where: u.id == ^identifier,
                 select: %{
                   u |
                   description: fragment("CAST(\"description\" AS varchar(8000))"),
                 },
                 limit: 1
    case JetzySchema.MSSQL.Repo.all(query) do
      [r | _] -> r
      _ -> nil
    end
  end

  def by_guid(guid, context, options \\ nil) do
    by_guid!(guid, context, options)
  end
  def by_guid!(guid, _context, _options \\ nil) do
    guid = String.upcase(guid)
    case JetzySchema.MSSQL.Repo.get_by(JetzySchema.MSSQL.Post.Table, [guid: guid]) do
      %{} = v -> v
      _ -> nil
    end
#    query = from u in JetzySchema.MSSQL.Post.Table,
#                 where: u.guid == ^guid,
#                 select: %{
#                   u |
#                   description: fragment("CAST(\"description\" AS varchar(8000))"),
#                 },
#                 limit: 1
#    case JetzySchema.MSSQL.Repo.all(query) do
#      [r | _] -> r
#      _ -> nil
#    end
  end



  def geo(%{__struct__: JetzySchema.MSSQL.Post.Table} = _record, _context, _options) do
    nil
  end

end
