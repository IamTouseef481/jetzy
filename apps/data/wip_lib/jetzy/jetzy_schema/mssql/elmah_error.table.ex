defmodule JetzySchema.MSSQL.ElmahError.Table do
  use Ecto.Schema
  @nmid_index 14

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"ELMAH_Error")
  # ENTRY ELMAH_Error JetzySchema.MSSQL.ElmahError.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 2/24/2020 9:51:35 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[ELMAH_Error](
  [ErrorId] [uniqueidentifier] NOT NULL,
  [Application] [nvarchar](60) NOT NULL,
  [Host] [nvarchar](50) NOT NULL,
  [Type] [nvarchar](100) NOT NULL,
  [Source] [nvarchar](60) NOT NULL,
  [Message] [nvarchar](500) NOT NULL,
  [User] [nvarchar](50) NOT NULL,
  [StatusCode] [int] NOT NULL,
  [TimeUtc] [datetime] NOT NULL,
  [Sequence] [int] IDENTITY(1,1) NOT NULL,
  [AllXml] [ntext] NOT NULL,
  CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED
  (
  [ErrorId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ErrorId"}
  @derive {Phoenix.Param, key: :id}
  schema "ELMAH_Error" do

    # CREATE TABLE [dbo].[ELMAH_Error](
    # field :error_id, Tds.Ecto.UUID, source: :"ErrorId"
    field :application, :string, source: :"Application"
    field :host, :string, source: :"Host"
    field :type, :string, source: :"Type"
    field :source, :string, source: :"Source"
    field :message, :string, source: :"Message"
    field :user, :string, source: :"User"
    field :status_code, :integer, source: :"StatusCode"
    field :time_utc, :utc_datetime, source: :"TimeUtc"
    field :sequence, :integer, source: :"Sequence"
    field :all_xml, :string, source: :"AllXml"


  end
end
