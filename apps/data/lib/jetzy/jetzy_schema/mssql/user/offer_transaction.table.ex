defmodule JetzySchema.MSSQL.User.Offer.Transaction.Table do
  use Ecto.Schema
  @nmid_index 62

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserOfferTransaction")
  # ENTRY UserOfferTransaction JetzySchema.MSSQL.User.OfferTransaction.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserOfferTransaction]    Script Date: 2/24/2020 10:33:02 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserOfferTransaction](
  [UserOfferId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [OfferId] [uniqueidentifier] NOT NULL,
  [Point] [numeric](18, 0) NOT NULL,
  [BalancePoint] [numeric](18, 0) NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifiedDate] [datetime] NULL,
  [IsCompleted] [bit] NOT NULL,
  [IsCanceled] [bit] NOT NULL,
  [Remarks] [varchar](500) NULL,
  CONSTRAINT [PK_UserOfferTransaction] PRIMARY KEY CLUSTERED
  (
  [UserOfferId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserOfferTransaction] ADD  CONSTRAINT [DF_UserOfferTransaction_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserOfferTransaction] ADD  CONSTRAINT [DF_UserOfferTransaction_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[UserOfferTransaction] ADD  CONSTRAINT [DF_UserOfferTransaction_IsCompleted]  DEFAULT ((0)) FOR [IsCompleted]
  GO

  ALTER TABLE [dbo].[UserOfferTransaction] ADD  CONSTRAINT [DF_UserOfferTransaction_IsCanceled]  DEFAULT ((0)) FOR [IsCanceled]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserOfferId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserOfferTransaction" do
    # CREATE TABLE [dbo].[UserOfferTransaction](
    # field :user_offer_id, :integer, source: :"UserOfferId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :offer_id, Tds.Ecto.UUID, source: :"OfferId"
    field :point, :decimal, precision: 18, source: :"Point"
    field :balance_point, :decimal, precision: 18, source: :"BalancePoint"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :is_completed, :boolean, source: :"IsCompleted"
    field :is_cancelled, :boolean, source: :"IsCanceled"
    field :remarks, :string, source: :"Remarks"
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.User.Offer.Transaction.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: nil
    }
  end
end
