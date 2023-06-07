defmodule JetzySchema.MSSQL.HadCdnUser.Table do
  use Ecto.Schema
  @nmid_index 16

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"HadCDNUsers")
  # ENTRY HadCDNUsers JetzySchema.MSSQL.HadCdnUser.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[HadCDNUsers]    Script Date: 2/24/2020 9:53:07 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[HadCDNUsers](
  [UserId] [uniqueidentifier] NOT NULL
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: false, source: :"UserId"}
  @derive {Phoenix.Param, key: :id}
  schema "HadCDNUsers" do
    # CREATE TABLE [dbo].[HadCDNUsers](
    # field :user_id, Tds.Ecto.UUID, source: :"UserId"
  end
end
