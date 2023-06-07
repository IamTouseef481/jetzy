defmodule JetzySchema.PG.Contact.Channel.Table do
  @moduledoc """
  table defined in  liquibase/1.0/005_user_extended.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_contact_channel)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_contact_channel" do
    field :channel_definition, JetzySchema.Types.Channel.Definition.Reference
    field :description, JetzySchema.Types.UserVersionedString.Reference

    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
