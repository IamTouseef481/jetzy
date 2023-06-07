defmodule JetzySchema.MSSQL.Interest.Table do
  use Ecto.Schema
  @nmid_index 17

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Interest")
  # ENTRY Interest JetzySchema.MSSQL.Interest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Interest]    Script Date: 2/24/2020 9:54:21 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Interest](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [InterestName] [nvarchar](50) NOT NULL,
  [Description] [nvarchar](max) NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  [Status] [bit] NULL,
  [BackGroundColor] [nvarchar](100) NULL,
  [ImageName] [nvarchar](250) NULL,
  [IsPrivate] [bit] NULL,
  [SmallImageName] [nvarchar](250) NULL,
  [IsDelete] [bit] NOT NULL,
  [IsGroupPrivate] [bit] NOT NULL,
  CONSTRAINT [PK_UserInetrests] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Interest] ADD  CONSTRAINT [DF_Interest_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[Interest] ADD  CONSTRAINT [DF_Interest_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[Interest] ADD  CONSTRAINT [DF_Interest_Status]  DEFAULT ((0)) FOR [Status]
  GO

  ALTER TABLE [dbo].[Interest] ADD  DEFAULT ((0)) FOR [IsPrivate]
  GO

  ALTER TABLE [dbo].[Interest] ADD  CONSTRAINT [DF__Interest__IsDele__43653C68]  DEFAULT ((0)) FOR [IsDelete]
  GO

  ALTER TABLE [dbo].[Interest] ADD  CONSTRAINT [DF_Interest_IsGroupPrivate]  DEFAULT ((0)) FOR [IsGroupPrivate]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "Interest" do
    # CREATE TABLE [dbo].[Interest](
    #field :id, :integer
    field :interest_name, :string, source: :"InterestName"
    field :description, :string, load_in_query: true, source: :"Description"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :status, :boolean, source: :"Status"
    field :back_ground_color, :string, source: :"BackGroundColor"
    field :image_name, :string, source: :"ImageName"
    field :private, :boolean, source: :"IsPrivate"
    field :small_image_name, :string, source: :"SmallImageName"
    field :deleted, :boolean, source: :"IsDelete"
    field :private_group, :boolean, source: :"IsGroupPrivate"
  end


  #-------------------------
  # profile_image/3
  #-------------------------
  def interest_image(%{__struct__: JetzySchema.MSSQL.Interest.Table} = record, _context, _options \\ nil) do
    cond do
      record.image_name && String.length(record.image_name) > 0 ->
        "https://api.jetzyapp.com/Images/Icon/#{record.image_name}"
      :else -> nil
    end
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Interest.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end


  def time_stamp!(%{__struct__: JetzySchema.MSSQL.Interest.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

end
