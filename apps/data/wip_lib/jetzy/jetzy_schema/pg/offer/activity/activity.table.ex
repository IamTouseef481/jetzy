defmodule JetzySchema.PG.Offer.Activity.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_offer_activity)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_offer_activity" do
    field :activity_source, JetzySchema.Types.Data.Source.Enum
    field :activity_type, JetzySchema.Types.Offer.Activity.Type.Enum

    field :subject, JetzySchema.Types.Universal.Reference

    field :description, JetzySchema.Types.VersionedActivity.Reference
    field :details, :integer # CMS - need to update to V3 Entity types

    field :featured, :integer
    field :display_discount, :integer
    field :active, :integer

    field :price, :integer
    field :duration, :integer

    field :valid_from, :utc_datetime_usec
    field :valid_until, :utc_datetime_usec

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
