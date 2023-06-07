defmodule JetzySchema.PG.User.Session.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_session)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_session" do
    field :user, JetzySchema.Types.User.Reference

    field :device, JetzySchema.Types.User.Device.Reference
    field :credential, JetzySchema.Types.User.Credential.Reference

    field :status, JetzySchema.Types.Session.Status.Enum
    field :generation, :integer

    # Time Stamps
    field :session_start, :utc_datetime_usec
    field :session_end, :utc_datetime_usec
    field :expire_after, :utc_datetime_usec
  end
end
