defmodule JetzySchema.MSSQL.Address.Post.Mapping.Table do
  use Ecto.Schema
  @nmid_index 4

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"AddressShoutoutMapping")
  # ENTRY AddressShoutoutMapping JetzySchema.MSSQL.Address.ShoutoutMapping.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[AddressShoutoutMapping]    Script Date: 2/24/2020 9:40:05 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[AddressShoutoutMapping](
  [ShoutoutMappingId] [bigint] IDENTITY(1,1) NOT NULL,
  [AddressComponentId] [uniqueidentifier] NOT NULL,
  [ShoutoutId] [bigint] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [oldMoment] [bit] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [ShoutoutMappingId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping] ADD  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping] ADD  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping] ADD  DEFAULT ((0)) FOR [oldMoment]
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping]  WITH CHECK ADD  CONSTRAINT [FK_AddressShoutoutMapping_Comments] FOREIGN KEY([AddressComponentId])
  REFERENCES [dbo].[AddressComponents] ([AddressComponentId])
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping] CHECK CONSTRAINT [FK_AddressShoutoutMapping_Comments]
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping]  WITH CHECK ADD  CONSTRAINT [FK_AddressShoutoutMapping_Comments2] FOREIGN KEY([ShoutoutId])
  REFERENCES [dbo].[UserShoutouts] ([ShoutoutId])
  GO

  ALTER TABLE [dbo].[AddressShoutoutMapping] CHECK CONSTRAINT [FK_AddressShoutoutMapping_Comments2]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ShoutoutMappingId"}
  @derive {Phoenix.Param, key: :id}
  schema "AddressShoutoutMapping" do
    #field :shoutout_mapping_id, :integer, source: :"ShoutoutMappingId"
    field :address_component_id, Tds.Ecto.UUID, source: :"AddressComponentId"
    field :post_id, :integer, source: :"ShoutoutId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
    field :old_moment, :boolean, source: :oldMoment
  end
end
