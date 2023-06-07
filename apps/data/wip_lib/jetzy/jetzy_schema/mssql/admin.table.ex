defmodule JetzySchema.MSSQL.Admin.Table do
  use Ecto.Schema
  @nmid_index 5

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Admin")
  # ENTRY Admin JetzySchema.MSSQL.Admin.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Admin]    Script Date: 2/24/2020 9:40:58 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Admin](
  [AdminId] [int] IDENTITY(1,1) NOT NULL,
  [FirstName] [nvarchar](100) NOT NULL,
  [LastName] [nvarchar](100) NOT NULL,
  [City] [nvarchar](100) NULL,
  [Password] [nvarchar](100) NOT NULL,
  [Email] [nvarchar](100) NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifyDate] [datetime] NULL,
  [RoleId] [numeric](18, 0) NULL,
  [IsSuperAdmin] [bit] NOT NULL,
  CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED
  (
  [AdminId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Admin] ADD  CONSTRAINT [DF_Admin_RoleId]  DEFAULT ((1)) FOR [RoleId]
  GO

  ALTER TABLE [dbo].[Admin] ADD  DEFAULT ((0)) FOR [IsSuperAdmin]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"AdminId"}
  @derive {Phoenix.Param, key: :id}
  schema "Admin" do
    # CREATE TABLE [dbo].[Admin](
    #field :admin_id, :integer, source: :"AdminId"
    field :first_name, :string, source: :"FirstName"
    field :last_name, :string, source: :"LastName"
    field :city, :string, source: :"City"
    field :password, :string, source: :"Password"
    field :email, :string, source: :"Email"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifyDate"
    field :role_id, :decimal, precision: 18, source: :"RoleId"
    field :is_super_admin, :boolean, source: :"IsSuperAdmin"
  end
end
