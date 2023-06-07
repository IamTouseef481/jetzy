defmodule JetzySchema.PG.User.Credential.JetzyBCrypt.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 14
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential__bcrypt)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential__bcrypt" do
    #  Fields and Secondary Relations
    field :login, :string
    field :password, :string

    #  Standard Time Stamps
    field :modified_on, :utc_datetime
  end
end
