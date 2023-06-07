defmodule JetzySchema.MSSQL.Restaurant.Table do
  use Ecto.Schema
  @nmid_index 36

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Restaurants")
  # ENTRY Restaurants JetzySchema.MSSQL.Restaurant.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Restaurants]    Script Date: 2/24/2020 10:13:12 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Restaurants](
  [RestaurantId] [int] IDENTITY(1,1) NOT NULL,
  [RestaurantName] [nvarchar](100) NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Latitude] [float] NULL,
  [Longitude] [float] NULL,
  [Address] [nvarchar](max) NULL,
  [IsDeleted] [bit] NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [RestaurantId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Restaurants] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[Restaurants] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO
  """

  @primary_key {:id, :id, autogenerate: true, source: :"RestaurantId"}
  @derive {Phoenix.Param, key: :id}
  schema "Restaurants" do
    # CREATE TABLE [dbo].[Restaurants](
    # field :restaurant_id, :integer, source: :"RestaurantId"
    field :restaurant_name, :string, source: :"RestaurantName"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :latitude, :float, source: :"Latitude"
    field :longitude, :float, source: :"Longitude"
    field :address, :string, source: :"Address"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
