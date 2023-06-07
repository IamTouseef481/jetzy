defmodule JetzySchema.MSSQL.Address.Component.Table do
  use Ecto.Schema
  @nmid_index 2
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"AddressComponents")
  # ENTRY AddressComponents JetzySchema.MSSQL.Address.Component.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[AddressComponents]    Script Date: 2/24/2020 9:38:41 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[AddressComponents](
  [AddressComponentId] [uniqueidentifier] NOT NULL,
  [place_id] [nvarchar](1000) NULL,
  [formatted_address] [nvarchar](1000) NULL,
  [url] [nvarchar](500) NULL,
  [colloquial_area] [nvarchar](500) NULL,
  [country] [nvarchar](500) NULL,
  [intersection] [nvarchar](500) NULL,
  [locality] [nvarchar](500) NULL,
  [neighborhood] [nvarchar](500) NULL,
  [premise] [nvarchar](500) NULL,
  [route] [nvarchar](500) NULL,
  [street_address] [nvarchar](500) NULL,
  [street_number] [nvarchar](500) NULL,
  [sublocality] [nvarchar](500) NULL,
  [sublocality_level_1] [nvarchar](500) NULL,
  [sublocality_level_2] [nvarchar](500) NULL,
  [sublocality_level_3] [nvarchar](500) NULL,
  [sublocality_level_4] [nvarchar](500) NULL,
  [sublocality_level_5] [nvarchar](500) NULL,
  [administrative_area_level_1] [nvarchar](500) NULL,
  [administrative_area_level_2] [nvarchar](500) NULL,
  [administrative_area_level_3] [nvarchar](500) NULL,
  [administrative_area_level_4] [nvarchar](500) NULL,
  [administrative_area_level_5] [nvarchar](500) NULL,
  [other] [nvarchar](max) NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [ApiVersion] [nvarchar](100) NULL,
  [IsNew] [bit] NULL,
  PRIMARY KEY CLUSTERED
  (
  [AddressComponentId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[AddressComponents] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[AddressComponents] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[AddressComponents] ADD  DEFAULT (NULL) FOR [IsNew]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"AddressComponentId"}
  @derive {Phoenix.Param, key: :id}
  schema "AddressComponents" do
    field :place_id, :string
    field :formatted_address, :string
    field :url, :string
    field :colloquial_area, :string
    field :country, :string
    field :intersection, :string
    field :locality, :string
    field :neighborhood, :string
    field :premise, :string
    field :route, :string
    field :street_address, :string
    field :street_number, :string
    field :sublocality, :string
    field :sublocality_level_1, :string
    field :sublocality_level_2, :string
    field :sublocality_level_3, :string
    field :sublocality_level_4, :string
    field :sublocality_level_5, :string
    field :administrative_area_level_1, :string
    field :administrative_area_level_2, :string
    field :administrative_area_level_3, :string
    field :administrative_area_level_4, :string
    field :administrative_area_level_5, :string
    field :other, :string, load_in_query: true
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :api_version, :string, source: :"ApiVersion"
    field :new, :boolean, source: :"IsNew"
  end
end
