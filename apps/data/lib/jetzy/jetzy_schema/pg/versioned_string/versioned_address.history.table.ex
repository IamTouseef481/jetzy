defmodule JetzySchema.PG.VersionedAddress.History.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 19
  JetzySchema.NoizuTableBehaviour.table(:vnext_versioned_address_history)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_address_history" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference
    field :versioned_address, JetzySchema.Types.VersionedAddress.Reference

    field :revision, :integer

    field :url, JetzySchema.Types.VersionedLink.Reference
    field :icon, JetzySchema.Types.Entity.Image.Reference

    field :name, JetzySchema.Types.Noizu.MarkdownField
    field :official_name, JetzySchema.Types.Noizu.MarkdownField
    field :description, JetzySchema.Types.Noizu.MarkdownField
    field :note, JetzySchema.Types.Noizu.MarkdownField

    field :address_type, JetzySchema.Types.Address.Type.Enum
    field :address_line_one, JetzySchema.Types.Noizu.MarkdownField
    field :address_line_two, JetzySchema.Types.Noizu.MarkdownField
    field :intersection, JetzySchema.Types.Noizu.MarkdownField
    field :postal_code, JetzySchema.Types.Noizu.MarkdownField

    field :address_country, JetzySchema.Types.Location.Country.Reference
    field :address_state, JetzySchema.Types.Location.State.Reference
    field :address_city, JetzySchema.Types.Location.City.Reference

    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec

  end
end
