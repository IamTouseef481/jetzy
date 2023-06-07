defmodule JetzySchema.PG.Offer.Table do
  @moduledoc """
  table defined in  liquibase/1.0/014_reward_system.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_offer)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_offer" do
    field :qty, :integer
    field :points, :integer
    field :tier, JetzySchema.Types.Reward.Tier.Reference
    field :redeem_type, JetzySchema.Types.Redeem.Type.Enum
    field :activity_type, JetzySchema.Types.Activity.Type.Enum

    field :active_from, :utc_datetime
    field :active_until, :utc_datetime
    
    field :description, JetzySchema.Types.VersionedString.Reference
    field :details, JetzySchema.Types.Universal.Reference # CMS

    field :status, JetzySchema.Types.Status.Enum

    field :location, JetzySchema.Types.Universal.Reference
    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer

    field :image, JetzySchema.Types.Entity.Image.Reference

    field :pinned, :boolean
    field :pin_date, :utc_datetime

    field :link, JetzySchema.Types.VersionedLink.Reference

    field :ticket_price, :float

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
