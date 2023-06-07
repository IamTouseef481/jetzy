defmodule JetzySchema.PG.User.Credential.JetzyLegacySession.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 16
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential__jetzy_legacy_session)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential__jetzy_legacy_session" do


    #  Fields and Secondary Relations
    field :guid, :string
    field :session, :string
    field :session_active, :integer
    field :recheck_after, :utc_datetime

    #  Standard Time Stamps
    field :modified_on, :utc_datetime
  end
end
