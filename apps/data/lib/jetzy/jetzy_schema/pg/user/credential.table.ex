defmodule JetzySchema.PG.User.Credential.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_credential)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential" do
    field :user, JetzySchema.Types.User.Reference

    field :origin, JetzySchema.Types.Origin.Source.Enum
    field :status, JetzySchema.Types.Status.Enum
    field :credential_type, JetzySchema.Types.Credential.Type.Enum
    field :credential_provider, JetzySchema.Types.Credential.Provider.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
