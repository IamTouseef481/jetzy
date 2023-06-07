defmodule JetzySchema.MSSQL.User.Geo.Location.Table do
  use Ecto.Schema
  @nmid_index 50

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserGeoLocation")
  # ENTRY UserGeoLocation JetzySchema.MSSQL.User.Geo.Location.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserGeoLocation]    Script Date: 2/24/2020 10:25:56 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserGeoLocation](
  [GeoLocationId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [GeoLocation] [geography] NULL,
  [Location] [nvarchar](1000) NULL,
  [Latitude] [float] NOT NULL,
  [Longitude] [float] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [IsActualLocation] [bit] NULL,
  [CityLatLongId] [uniqueidentifier] NULL,
  PRIMARY KEY CLUSTERED
  (
  [GeoLocationId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserGeoLocation] ADD  CONSTRAINT [DF_UserGeoLocation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserGeoLocation] ADD  CONSTRAINT [DF_UserGeoLocation_UpdatedOn]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[UserGeoLocation] ADD  DEFAULT ((0)) FOR [IsActualLocation]
  GO

  ALTER TABLE [dbo].[UserGeoLocation]  WITH CHECK ADD FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"GeoLocationId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserGeoLocation" do
    # CREATE TABLE [dbo].[UserGeoLocation](
    # field :geo_location_id, Tds.Ecto.UUID, source: :"GeoLocationId"
    field :user, Tds.Ecto.UUID, source: :"UserId"
    #field :geo_location, JetzySchema.Types.Geography, source: :"GeoLocation"
    field :location, :string, source: :"Location"
    field :latitude, :float, source: :"Latitude"
    field :longitude, :float, source: :"Longitude"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :is_actual_location, :boolean, source: :"IsActualLocation"
    field :city, Tds.Ecto.UUID, source: :"CityLatLongId"
  end


  def time_stamp(%{__struct__: JetzySchema.MSSQL.User.Geo.Location.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end


end
