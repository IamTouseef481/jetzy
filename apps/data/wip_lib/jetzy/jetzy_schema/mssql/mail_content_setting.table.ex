defmodule JetzySchema.MSSQL.MailContentSetting.Table do
  use Ecto.Schema
  @nmid_index 21

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"MailContentSetting")
  # ENTRY MailContentSetting JetzySchema.MSSQL.MailContentSetting.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[MailContentSetting]    Script Date: 2/24/2020 9:57:39 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[MailContentSetting](
  [MessageID] [int] IDENTITY(1,1) NOT NULL,
  [Subject] [nvarchar](max) NULL,
  [BodyText] [nvarchar](max) NULL,
  [Description] [nvarchar](max) NULL,
  [From] [nvarchar](max) NULL,
  [BCC] [nvarchar](max) NULL,
  [IsActive] [bit] NULL,
  CONSTRAINT [PK_MailContentSetting] PRIMARY KEY CLUSTERED
  (
  [MessageID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[MailContentSetting] ADD  CONSTRAINT [DF_MailContentSetting_Status]  DEFAULT ((1)) FOR [IsActive]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"MessageID"}
  @derive {Phoenix.Param, key: :id}
  schema "MailContentSetting" do
    # CREATE TABLE [dbo].[MailContentSetting](
    #field :message_i_d, :integer, source: :"MessageID"
    field :subject, :string, source: :"Subject"
    field :body_text, :string, source: :"BodyText"
    field :description, :string, source: :"Description"
    field :from, :string, source: :"From"
    field :bcc, :string, source: :"BCC"
    field :is_active, :boolean, source: :"IsActive"
  end
end
