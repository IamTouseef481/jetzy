defmodule JetzySchema.MSSQL.User.Country.Table do
  use Ecto.Schema
  @nmid_index 45

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserCountry")
  # ENTRY UserCountry JetzySchema.MSSQL.User.Country.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserCountry]    Script Date: 2/24/2020 10:22:07 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserCountry](
  [UserCountryId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [City] [nvarchar](100) NOT NULL,
  [Country] [nvarchar](100) NULL,
  [FromDate] [datetime] NULL,
  [ToDate] [datetime] NULL,
  CONSTRAINT [PK_UserCountry] PRIMARY KEY CLUSTERED
  (
  [UserCountryId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserCountry]  WITH CHECK ADD  CONSTRAINT [FK_UserCountry_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserCountry] CHECK CONSTRAINT [FK_UserCountry_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserCountryId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserCountry" do
    # CREATE TABLE [dbo].[UserCountry](
    # field :user_country_id, :integer, source: :"UserCountryId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :city, :string, source: :"City"
    field :country, :string, source: :"Country"
    field :from_date, :utc_datetime, source: :"FromDate"
    field :to_date, :utc_datetime, source: :"ToDate"
  end
end
