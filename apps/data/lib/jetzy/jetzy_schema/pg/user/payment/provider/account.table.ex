defmodule JetzySchema.PG.User.Payment.Provider.Account.Table do
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_payment_provider_account)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_payment_provider_account" do
    field :user, JetzySchema.Types.User.Reference
    field :payment_provider, JetzySchema.Types.Payment.Provider.Reference
    field :account, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end
end
