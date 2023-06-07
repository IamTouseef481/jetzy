defmodule JetzySchema.PG.Video.Table do
  @moduledoc """
  table defined in  liquibase/1.0/003_content.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_video)

  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_video" do
    field :uploader, JetzySchema.Types.Universal.Reference

    field :uuid, :string
    field :hash, :string
    field :thumbnail, JetzySchema.Types.Image.Reference
    field :blur_hash, :string
    field :base, :string
    field :source, :string

    field :external, :boolean
    field :image_type, JetzySchema.Types.Image.Type.Enum
    field :file_format, JetzySchema.Types.File.Format.Enum

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :content_flag, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
