defmodule JetzySchema.MSSQL.PrivateInterestCode.Table do
  use Ecto.Schema
  @nmid_index 31

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"PrivateInterestsCodes")
  # ENTRY PrivateInterestsCodes JetzySchema.MSSQL.PrivateInterestCode.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[PrivateInterestsCodes]    Script Date: 2/24/2020 10:02:02 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[PrivateInterestsCodes](
  [ReferalCode] [varchar](max) NULL,
  [interestID] [int] NULL
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO



  """

  schema "PrivateInterestsCodes" do
    # CREATE TABLE [dbo].[PrivateInterestsCodes](
    field :referal_code, :string, source: :"ReferalCode"
    field :interest_id, :integer, source: :interestID
  end
end
