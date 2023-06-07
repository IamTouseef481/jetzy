defmodule JetzySchema.PG.Comment.Table do
  @moduledoc """
  table defined in  liquibase/1.0/007_user_context.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_comment)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_comment" do
    field :subject_type, JetzySchema.Types.UniversalIdentifierResolution.Source.Enum
    field :subject, JetzySchema.Types.Universal.Reference
    field :owner, JetzySchema.Types.Universal.Reference

    field :status, JetzySchema.Types.Status.Enum
    field :comment_type, JetzySchema.Types.Comment.Type.Enum

    field :snippet, JetzySchema.Types.CommentVersionedString.Reference
    field :content, JetzySchema.Types.Universal.Reference # CMS

    field :location, JetzySchema.Types.Universal.Reference
    field :geo_latitude, :float
    field :geo_longitude, :float
    field :geo_radius, :float
    field :geo_zone, :integer

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    field :parent, JetzySchema.Types.Universal.Reference
    field :path_depth, :integer
    field :path_a11, :integer
    field :path_a12, :integer
    field :path_a21, :integer
    field :path_a22, :integer
    field :path_left, :float, virtual: true
    field :path_right, :float, virtual: true

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end



