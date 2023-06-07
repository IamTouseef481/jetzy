defmodule JetzySchema.PG.User.Firebase.Lookup.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_firebase_lookup)
  @primary_key {:identifier, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_firebase_lookup" do
    #  Fields and Secondary Relations
    field :user, JetzySchema.Types.User.Reference
    field :firebase, :string
    field :status, JetzySchema.Types.Status.Enum
  end
end
