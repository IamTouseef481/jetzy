defmodule JetzySchema.PG.User.Relative.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_relative)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_relative" do
    field :user, JetzySchema.Types.Universal.Reference
    field :relative, JetzySchema.Types.Universal.Reference
    field :user_relative_request, JetzySchema.Types.Universal.Reference
    field :status, JetzySchema.Types.Status.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
