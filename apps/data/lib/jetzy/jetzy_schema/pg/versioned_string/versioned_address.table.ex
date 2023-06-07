defmodule JetzySchema.PG.VersionedAddress.Table do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_versioned_address)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_versioned_address" do
    #  Fields and Secondary Relations
    field :editor, JetzySchema.Types.Universal.Reference

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


  def delete_history(ref, _context, _options \\ nil) do
    ref = Noizu.ERP.ref(ref)
    delete_query = from h in JetzySchema.PG.VersionedAddress.History.Table,
                        where: h.versioned_address == ^ref
    JetzySchema.PG.Repo.delete_all(delete_query)
  end

end
