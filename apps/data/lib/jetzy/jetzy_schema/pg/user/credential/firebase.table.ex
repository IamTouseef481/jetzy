defmodule JetzySchema.PG.User.Credential.Firebase.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 12
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential__firebase)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential__firebase" do
    #  Fields and Secondary Relations
    field :firebase_user, :string

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end
end
