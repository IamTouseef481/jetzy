defmodule JetzySchema.PG.User.Credential.Social.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  @nmid_index 341
  JetzySchema.NoizuTableBehaviour.table(:vnext_user_credential__social)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_credential__social" do
    #  Fields and Secondary Relations
    field :social_identifier, :string
    field :social_type, JetzySchema.Types.Social.Type.Enum

    #  Standard Time Stamps
    field :modified_on, :utc_datetime_usec
  end
end
