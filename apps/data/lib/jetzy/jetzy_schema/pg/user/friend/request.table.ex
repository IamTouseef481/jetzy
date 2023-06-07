defmodule JetzySchema.PG.User.Friend.Request.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_friend_request)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_friend_request" do
    field :user, JetzySchema.Types.Universal.Reference
    field :friend, JetzySchema.Types.Universal.Reference
    field :status, JetzySchema.Types.Status.Enum

    field :requested_on, :utc_datetime
    field :responded_on, :utc_datetime
    field :viewed_on, :utc_datetime

    field :request, JetzySchema.Types.VersionedString.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
