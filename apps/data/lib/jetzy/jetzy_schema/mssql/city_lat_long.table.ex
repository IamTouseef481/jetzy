defmodule JetzySchema.MSSQL.CityLatLong.Table do
  use Ecto.Schema
  @nmid_index 8

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"CityLatLongs")
  # ENTRY CityLatLongs JetzySchema.MSSQL.CityLatLong.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[CityLatLongs]    Script Date: 2/24/2020 9:44:55 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[CityLatLongs](
  [LatLongId] [uniqueidentifier] NOT NULL,
  [City] [nvarchar](100) NULL,
  [State] [nvarchar](100) NULL,
  [Country] [nvarchar](100) NULL,
  [ZipCode] [nvarchar](25) NULL,
  [Location] [nvarchar](25) NULL,
  [Latitude] [decimal](10, 6) NULL,
  [Longitude] [decimal](10, 6) NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_CityLatLongs] PRIMARY KEY CLUSTERED
  (
  [LatLongId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[CityLatLongs] ADD  DEFAULT (NULL) FOR [Latitude]
  GO

  ALTER TABLE [dbo].[CityLatLongs] ADD  DEFAULT (NULL) FOR [Longitude]
  GO

  ALTER TABLE [dbo].[CityLatLongs] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[CityLatLongs] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"LatLongId"}
  @derive {Phoenix.Param, key: :id}
  schema "CityLatLongs" do
    # CREATE TABLE [dbo].[CityLatLongs](
    #field :lat_long_id, Tds.Ecto.UUID, source: :"LatLongId"
    field :city, :string, source: :"City"
    field :state, :string, source: :"State"
    field :country, :string, source: :"Country"
    field :zip_code, :string, source: :"ZipCode"
    field :location, :string, source: :"Location"
    field :latitude, :decimal, precision: 10, scale: 6, source: :"Latitude"
    field :longitude, :decimal, precision: 10, scale: 6, source: :"Longitude"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
