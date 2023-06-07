defmodule JetzySchema.PG.Entity.Image.Table do
  @moduledoc """
  table defined in  liquibase/1.0/003_content.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_image)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_image" do
    field :subject, JetzySchema.Types.Universal.Reference
    field :image, JetzySchema.Types.Image.Reference


    field :status, JetzySchema.Types.Status.Enum

    field :location, JetzySchema.Types.Universal.Reference

    field :locale_language, JetzySchema.Types.Locale.Language.Enum
    field :locale_country, JetzySchema.Types.Locale.Country.Enum
    field :localized, :boolean

    field :description, JetzySchema.Types.VersionedString.Reference

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
