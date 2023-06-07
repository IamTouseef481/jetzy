defmodule JetzySchema.MSSQL.User.Report.Table do
  use Ecto.Schema
  @nmid_index 70

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserReport")
  # ENTRY UserReport JetzySchema.MSSQL.User.Report.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserReport]    Script Date: 2/24/2020 10:40:11 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserReport](
  [ReportId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [ReportedId] [nvarchar](100) NOT NULL,
  [ReportType] [int] NULL,
  [Description] [nvarchar](1000) NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [ReportId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserReport] ADD  CONSTRAINT [DF_UserReport_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[UserReport] ADD  CONSTRAINT [DF_UserReport_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserReport] ADD  CONSTRAINT [DF_UserReport_UpdatedOn]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"ReportId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserReport" do
    # CREATE TABLE [dbo].[UserReport](
    # field :report_id, Tds.Ecto.UUID, source: :"ReportId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :reported_id, :string, source: :"ReportedId"
    field :report_type, :integer, source: :"ReportType"
    field :description, :string, source: :"Description"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
