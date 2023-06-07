defmodule JetzySchema.PG.Location.Image.Table do
  @moduledoc """
  table defined in  liquibase/1.0/008_locations.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_location_image)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_location_image" do
    field :location, JetzySchema.Types.Universal.Reference
    field :image, JetzySchema.Types.Image.Reference

    field :locale_language, JetzySchema.Types.Locale.Language.Enum
    field :locale_country, JetzySchema.Types.Locale.Country.Enum
    field :localized, :boolean
    field :description, JetzySchema.Types.VersionedImageString.Reference

    field :status, JetzySchema.Types.Status.Enum
    field :added_by, JetzySchema.Types.Universal.Reference
    field :location_image_type, JetzySchema.Types.Location.Image.Type.Enum
    field :weight, :integer


    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :content_flag, JetzySchema.Types.Content.Flag.Enum
    field :sphinx_index, JetzySchema.Types.Sphinx.Index.Type.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
