defmodule JetzySchema.PG.Credential.Provider.Generation.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 10
  JetzySchema.NoizuTableBehaviour.table(:vnext_credential_provider_generation)

  @primary_key false
  schema "vnext_credential_provider_generation" do

    field :credential_provider, JetzySchema.Types.Credential.Provider.Enum, primary_key: true
    field :credential_type, JetzySchema.Types.Credential.Type.Enum, primary_key: true
    field :generation, :integer
  end
end
