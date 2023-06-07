defmodule JetzySchema.PG.User.Relative.Request.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_relative_request)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_relative_request" do
    field :user, JetzySchema.Types.Universal.Reference
    field :relative, JetzySchema.Types.Universal.Reference
    field :relative_type, JetzySchema.Types.Relative.Type.Enum
    field :from_user_relative_request, JetzySchema.Types.Universal.Reference

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
