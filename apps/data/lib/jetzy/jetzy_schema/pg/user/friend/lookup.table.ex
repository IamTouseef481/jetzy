defmodule JetzySchema.PG.User.Friend.Lookup.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_friend_lookup)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_friend_lookup" do
    field :user, JetzySchema.Types.Universal.Reference
    field :friend, JetzySchema.Types.Universal.Reference
    field :source, JetzySchema.Types.Universal.Reference

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
