defmodule JetzySchema.MSSQL.Report.Source.Table do
  use Ecto.Schema
  @nmid_index 35

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"ReportSources")
  # ENTRY ReportSources JetzySchema.MSSQL.Report.Source.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[ReportSources]    Script Date: 2/24/2020 10:12:28 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[ReportSources](
  [ReportSourceId] [bigint] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](250) NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [ReportSourceId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[ReportSources] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[ReportSources] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ReportSourceId"}
  @derive {Phoenix.Param, key: :id}
  schema "ReportSources" do
    # CREATE TABLE [dbo].[ReportSources](
    # field :report_source_identifier, :integer, source: :"ReportSourceId"
    field :name, :string, source: :"Name"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
