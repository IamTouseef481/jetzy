defmodule JetzySchema.PG.User.Follow.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_follow)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_follow" do
    field :user, JetzySchema.Types.User.Reference
    field :follow, JetzySchema.Types.User.Reference

    field :status, JetzySchema.Types.Status.Enum
    field :followed_on, :utc_datetime

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
