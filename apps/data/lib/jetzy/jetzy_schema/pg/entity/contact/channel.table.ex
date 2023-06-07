defmodule JetzySchema.PG.Entity.Contact.Channel.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_entity_contact_channel)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_entity_contact_channel" do
    field :subject, JetzySchema.Types.Universal.Reference
    field :description, JetzySchema.Types.UserVersionedString.Reference

    field :weight, :integer
    field :status, JetzySchema.Types.Status.Enum
    field :channel_type, JetzySchema.Types.Channel.Type.Enum
    field :channel, JetzySchema.Types.Contact.Channel.Reference

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
