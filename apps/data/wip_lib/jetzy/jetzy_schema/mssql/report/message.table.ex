defmodule JetzySchema.MSSQL.Report.Message.Table do
  use Ecto.Schema
  @nmid_index 34

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"ReportMessages")
  # ENTRY ReportMessages JetzySchema.MSSQL.Report.Message.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[ReportMessages]    Script Date: 2/24/2020 10:11:11 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[ReportMessages](
  [ReportMessageId] [bigint] IDENTITY(1,1) NOT NULL,
  [ReportSourceId] [int] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [ItemId] [bigint] NOT NULL,
  [Description] [nvarchar](max) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [ReportMessageId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[ReportMessages] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[ReportMessages] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[ReportMessages] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[ReportMessages]  WITH CHECK ADD  CONSTRAINT [FK_ReportMessages_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[ReportMessages] CHECK CONSTRAINT [FK_ReportMessages_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ReportMessageId"}
  @derive {Phoenix.Param, key: :id}
  schema "ReportMessages" do
    # CREATE TABLE [dbo].[ReportMessages](
    # field :report_message_id, :integer, source: :"ReportMessageId"
    field :report_source_identifier, :integer, source: :"ReportSourceId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :item_id, :integer, source: :"ItemId"
    field :description, :string, source: :"Description"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
