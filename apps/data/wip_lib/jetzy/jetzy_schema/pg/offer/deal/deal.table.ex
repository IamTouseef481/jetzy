defmodule JetzySchema.PG.Offer.Deal.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_offer_deal)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_offer_deal" do
    field :deal_source, JetzySchema.Types.Data.Source.Enum
    field :deal_type, JetzySchema.Types.Offer.Deal.Type.Enum
    field :deal_category, JetzySchema.Types.Offer.Deal.Category.Enum

    field :subject, JetzySchema.Types.Universal.Reference
    field :description, JetzySchema.Types.VersionedDeal.Reference
    field :details, :integer # CMS - need to update to V3 Entity types

    field :featured, :integer
    field :display_discount, :integer
    field :active, :integer
    field :user_limit, :integer

    field :valid_from, :utc_datetime
    field :valid_until, :utc_datetime

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
