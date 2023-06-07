defmodule JetzySchema.MSSQL.User.Inquiry.Table do
  use Ecto.Schema
  @nmid_index 53

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserInquiry")
  # ENTRY UserInquiry JetzySchema.MSSQL.User.Inquiry.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserInquiry]    Script Date: 2/24/2020 10:28:32 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserInquiry](
  [InquiryId] [bigint] IDENTITY(1,1) NOT NULL,
  [ToAddress] [nvarchar](100) NOT NULL,
  [CCAddress] [nvarchar](100) NULL,
  [BccAddress] [nvarchar](100) NULL,
  [Subject] [nvarchar](1000) NOT NULL,
  [Description] [nvarchar](max) NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  CONSTRAINT [PK_UserInquiry] PRIMARY KEY CLUSTERED
  (
  [InquiryId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserInquiry] ADD  CONSTRAINT [DF_UserInquiry_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserInquiry] ADD  CONSTRAINT [DF_UserInquiry_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserInquiry]  WITH CHECK ADD  CONSTRAINT [FK_UserInquiry_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserInquiry] CHECK CONSTRAINT [FK_UserInquiry_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"InquiryId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserInquiry" do
    # CREATE TABLE [dbo].[UserInquiry](
    # field :inquiry_id, :integer, source: :"InquiryId"
    field :to_address, :string, source: :"ToAddress"
    field :cc_address, :string, source: :"CCAddress"
    field :bcc_address, :string, source: :"BccAddress"
    field :subject, :string, source: :"Subject"
    field :description, :string, source: :"Description"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
  end
end
