defmodule JetzySchema.MSSQL.Status.Table do
  use Ecto.Schema
  @nmid_index 41

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Status")
  # ENTRY Status JetzySchema.MSSQL.Status.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Status]    Script Date: 2/24/2020 10:19:07 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Status](
  [Id] [int] NOT NULL,
  [Status] [nvarchar](50) NULL,
  CONSTRAINT [PK_InterestStatus] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "Status" do
    # CREATE TABLE [dbo].[Status](
    # field :id, :integer
    field :status, :string, source: :"Status"
  end
end
