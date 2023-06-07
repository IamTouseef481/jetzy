defmodule JetzySchema.PG.User.Session.Generation.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 18
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_session_generation)

  @primary_key false
  schema "vnext_user_session_generation" do
    field :user, JetzySchema.Types.User.Reference, primary_key: true
    field :generation, :integer
  end
end
