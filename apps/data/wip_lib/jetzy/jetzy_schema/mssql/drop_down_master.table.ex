defmodule JetzySchema.MSSQL.DropDownMaster.Table do
  use Ecto.Schema
  @nmid_index 12

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"DropDownMasterTable")
  # ENTRY DropDownMasterTable JetzySchema.MSSQL.DropDownMaster.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[DropDownMasterTable]    Script Date: 2/24/2020 9:49:07 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[DropDownMasterTable](
  [MasterId] [int] IDENTITY(1,1) NOT NULL,
  [Name] [varchar](150) NULL,
  [IsChildControl] [bit] NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  [Section] [nvarchar](200) NULL,
  PRIMARY KEY CLUSTERED
  (
  [MasterId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"MasterId"}
  @derive {Phoenix.Param, key: :id}
  schema "DropDownMasterTable" do

    # CREATE TABLE [dbo].[DropDownMasterTable](
    #field :master_id, :integer, source: :"MasterId"
    field :name, :string, source: :"Name"
    field :is_child_control, :boolean, source: :"IsChildControl"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :section, :string, source: :"Section"
  end
end
