defmodule JetzySchema.PG.User.Credential.JetzyLegacy.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 15
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential__jetzy_legacy)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential__jetzy_legacy" do
    #  Fields and Secondary Relations
    field :guid, :string
    field :login_name, :string
    field :password_hash, :string

    #  Standard Time Stamps
    field :modified_on, :utc_datetime
  end
end
