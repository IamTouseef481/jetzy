defmodule JetzySchema.MSSQL.DropDownSubMaster.Table do
  use Ecto.Schema
  @nmid_index 13

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"DropDownSubMasterTable")
  # ENTRY DropDownSubMasterTable JetzySchema.MSSQL.DropDownSubMaster.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[DropDownSubMasterTable]    Script Date: 2/24/2020 9:50:22 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[DropDownSubMasterTable](
  [SubMasterId] [int] IDENTITY(1,1) NOT NULL,
  [MasterId] [int] NULL,
  [Name] [varchar](150) NULL,
  [SortOrder] [int] NULL,
  [Status] [int] NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  [CreatedBy] [bigint] NULL,
  [UpdatedBy] [bigint] NULL,
  PRIMARY KEY CLUSTERED
  (
  [SubMasterId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"SubMasterId"}
  @derive {Phoenix.Param, key: :id}
  schema "DropDownSubMasterTable" do
    # CREATE TABLE [dbo].[DropDownSubMasterTable](
    #field :sub_master_id, :integer, source: :"SubMasterId"
    field :master_id, :integer, source: :"MasterId"
    field :name, :string, source: :"Name"
    field :sort_order, :integer, source: :"SortOrder"
    field :status, :integer, source: :"Status"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :created_by, :integer, source: :"CreatedBy"
    field :modified_by, :integer, source: :"UpdatedBy"
  end
end
