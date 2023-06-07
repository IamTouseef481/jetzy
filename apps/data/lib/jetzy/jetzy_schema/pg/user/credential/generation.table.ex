defmodule JetzySchema.PG.User.Credential.Generation.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 13
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential_generation)

  @primary_key false
  schema "vnext_user_credential_generation" do
    field :user_credential, JetzySchema.Types.User.Credential.Reference, primary_key: true
    field :generation, :integer
  end
end
