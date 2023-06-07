defmodule JetzySchema.PG.Business.Hotel.Location.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_hotel_location)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_hotel_location" do
    field :hotel, JetzySchema.Types.Business.Hotel.Reference
    field :location, JetzySchema.Types.Universal.Reference
    field :description, JetzySchema.Types.VersionedBusiness.Reference
    field :details, :integer # CMS - need to update to V3 Entity types

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
