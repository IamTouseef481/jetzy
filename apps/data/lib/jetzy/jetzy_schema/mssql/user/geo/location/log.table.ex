defmodule JetzySchema.MSSQL.User.Geo.Location.Log.Table do
  use Ecto.Schema
  @nmid_index 51

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserGeoLocationLog")
  # ENTRY UserGeoLocationLog JetzySchema.MSSQL.User.Geo.Location.Log.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserGeoLocationLog]    Script Date: 2/24/2020 10:26:28 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserGeoLocationLog](
  [GeoLocationLogId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [GeoLocation] [geography] NULL,
  [Location] [nvarchar](1000) NULL,
  [Latitude] [float] NOT NULL,
  [Longitude] [float] NOT NULL,
  [IsActualLocation] [bit] NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [LogCreatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [GeoLocationLogId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserGeoLocationLog] ADD  DEFAULT ((0)) FOR [IsActualLocation]
  GO

  ALTER TABLE [dbo].[UserGeoLocationLog] ADD  CONSTRAINT [DF_UserGeoLocationLog_CreatedDate]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserGeoLocationLog] ADD  CONSTRAINT [DF_UserGeoLocationLog_UpdatedOn]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[UserGeoLocationLog] ADD  CONSTRAINT [DF_UserGeoLocationLog_LogCreatedOn]  DEFAULT (getdate()) FOR [LogCreatedOn]
  GO

  ALTER TABLE [dbo].[UserGeoLocationLog]  WITH CHECK ADD FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"GeoLocationLogId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserGeoLocationLog" do

    # CREATE TABLE [dbo].[UserGeoLocationLog](
    # field :geo_location_log_id, Tds.Ecto.UUID, source: :"GeoLocationLogId"
    field :user, Tds.Ecto.UUID, source: :"UserId"
    #field :geo_location, JetzySchema.Types.Geography, source: :"GeoLocation"
    field :location, :string, source: :"Location"
    field :latitude, :float, source: :"Latitude"
    field :longitude, :float, source: :"Longitude"
    field :is_actual_location, :boolean, source: :"IsActualLocation"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :log_created_on, :utc_datetime, source: :"LogCreatedOn"

  end


  def time_stamp(%{__struct__: JetzySchema.MSSQL.User.Geo.Location.Log.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end

end
