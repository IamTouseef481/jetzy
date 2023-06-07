defmodule JetzySchema.PG.User.Device.Session.Generation.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 17
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_device_session_generation)

  @primary_key false
  schema "vnext_user_device_session_generation" do
    field :user_device, JetzySchema.Types.User.Device.Reference, primary_key: true
    field :generation, :integer
  end
end
