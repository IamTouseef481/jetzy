defmodule JetzySchema.MSSQL.Address.MomentMapping.Table do
  use Ecto.Schema
  @nmid_index 3

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"AddressMomentMapping")
  # ENTRY AddressMomentMapping JetzySchema.MSSQL.Address.MomentMapping.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[AddressMomentMapping]    Script Date: 2/24/2020 9:39:05 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[AddressMomentMapping](
  [AddressMomentMappingId] [uniqueidentifier] NOT NULL,
  [AddressComponentId] [uniqueidentifier] NOT NULL,
  [MomentId] [uniqueidentifier] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [ApiVersion] [nvarchar](100) NULL,
  [IsNew] [bit] NULL,
  PRIMARY KEY CLUSTERED
  (
  [AddressMomentMappingId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[AddressMomentMapping] ADD  CONSTRAINT [DF_AddressMomentMappingId]  DEFAULT (newid()) FOR [AddressMomentMappingId]
  GO

  ALTER TABLE [dbo].[AddressMomentMapping] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[AddressMomentMapping] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[AddressMomentMapping] ADD  DEFAULT (NULL) FOR [IsNew]
  GO

  ALTER TABLE [dbo].[AddressMomentMapping]  WITH CHECK ADD FOREIGN KEY([AddressComponentId])
  REFERENCES [dbo].[AddressComponents] ([AddressComponentId])
  GO

  ALTER TABLE [dbo].[AddressMomentMapping]  WITH NOCHECK ADD FOREIGN KEY([MomentId])
  REFERENCES [dbo].[UserMoments] ([MomentId])
  GO



  """


  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"AddressMomentMappingId"}
  @derive {Phoenix.Param, key: :id}
  schema "AddressMomentMapping" do
    field :address_component_id, Tds.Ecto.UUID, source: :"AddressComponentId"
    field :moment_id, Tds.Ecto.UUID, source: :"MomentId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :api_version, :string, source: :"ApiVersion"
    field :new, :boolean, source: :"IsNew"
  end
end
