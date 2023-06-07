defmodule JetzySchema.MSSQL.HadCdnMoment.Table do
  use Ecto.Schema
  @nmid_index 15

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"HadCDNMoments")
  # ENTRY HadCDNMoments JetzySchema.MSSQL.HadCdnMoment.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[HadCDNMoments]    Script Date: 2/24/2020 9:52:30 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[HadCDNMoments](
  [MomentId] [uniqueidentifier] NOT NULL
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: false, source: :"MomentId"}
  @derive {Phoenix.Param, key: :id}
  schema "HadCDNMoments" do
    # CREATE TABLE [dbo].[HadCDNMoments](
  end
end
