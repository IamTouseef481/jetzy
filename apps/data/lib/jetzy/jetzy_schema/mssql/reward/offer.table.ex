defmodule JetzySchema.MSSQL.Reward.Offer.Table do
  use Ecto.Schema
  import Ecto.Query
  @nmid_index 38

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"RewardOffer")
  # ENTRY RewardOffer JetzySchema.MSSQL.Reward.Offer.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[RewardOffer]    Script Date: 2/24/2020 10:15:31 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[RewardOffer](
  [RewardOfferId] [uniqueidentifier] NOT NULL,
  [OfferName] [nvarchar](100) NOT NULL,
  [PointRequired] [bigint] NOT NULL,
  [TierId] [int] NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifyDate] [datetime] NULL,
  [IsDeleted] [bit] NOT NULL,
  [OfferDescription] [nvarchar](max) NULL,
  [ImageName] [nvarchar](250) NULL,
  [MultiRedeemAllowed] [bit] NULL,
  CONSTRAINT [PK_RewardOffer] PRIMARY KEY CLUSTERED
  (
  [RewardOfferId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[RewardOffer] ADD  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[RewardOffer] ADD  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[RewardOffer] ADD  CONSTRAINT [default_MultiRedeemAllowed]  DEFAULT ((1)) FOR [MultiRedeemAllowed]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"RewardOfferId"}
  @derive {Phoenix.Param, key: :id}
  schema "RewardOffer" do
    # CREATE TABLE [dbo].[RewardOffer](
    # field :reward_offer_id, Tds.Ecto.UUID, source: :"RewardOfferId"
    field :offer_name, :string, source: :"OfferName"
    field :points_required, :integer, source: :"PointRequired"
    field :tier_id, :integer, source: :"TierId"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifyDate"
    field :deleted, :boolean, source: :"IsDeleted"
    field :offer_description, :string, source: :"OfferDescription"
    field :image_name, :string, source: :"ImageName"
    field :multi_redeem_allowed, :boolean, source: :"MultiRedeemAllowed"
    field :latitude, :decimal, source: :"Latitude"
    field :longitude, :decimal, source: :"Longitude"
    field :pinned, :boolean, source: :"IsPinned"
    field :event_start_date, :utc_datetime, source: :"EventStartDate"
    field :event_end_date, :utc_datetime, source: :"EventEndDate"
    field :pinned_date, :utc_datetime, source:  :"PinDate"
    field :price_of_ticket, :decimal, source: :"PriceOfTicket"
    field :link, :string, source: :"Link"
    field :location, :string, source: :"Location"
  end


  def offer_images(guid, _context, _options) do
    query = from u in JetzySchema.MSSQL.Reward.Image.Table,
                 where: u.reward_offer_id == ^guid
    JetzySchema.MSSQL.Repo.all(query)
  end

  def time_stamp(%{__struct__: JetzySchema.MSSQL.Reward.Offer.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

end
