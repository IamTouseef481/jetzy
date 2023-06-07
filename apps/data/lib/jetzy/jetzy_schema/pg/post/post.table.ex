defmodule JetzySchema.PG.Post.Table do
  @moduledoc """
  table defined in  liquibase/1.0/007_user_context.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_post)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_post" do
    field :owner, JetzySchema.Types.Universal.Reference

    field :snippet, JetzySchema.Types.PostVersionedString.Reference
    field :content, JetzySchema.Types.Universal.Reference # CMS

    field :post_topic, JetzySchema.Types.Post.Topic.Enum
    field :post_type, JetzySchema.Types.Post.Type.Enum
    field :media_type, JetzySchema.Types.Media.Type.Enum
    field :status, JetzySchema.Types.Status.Enum
    field :visibility, JetzySchema.Types.Visibility.Type.Enum

    field :location, JetzySchema.Types.Universal.Reference
    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer


    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    field :event_start_date, :date
    field :event_start_time, :time

    field :event_end_date, :date
    field :event_end_time, :time

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
