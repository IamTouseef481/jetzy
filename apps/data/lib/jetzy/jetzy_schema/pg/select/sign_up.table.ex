defmodule JetzySchema.PG.Select.SignUp.Table do
  @moduledoc """
  table defined in  liquibase/1.0/017_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_select_sign_up)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_select_sign_up" do
    field :status, Ecto.Enum, values: [:approved, :pending, :review, :denied]
    field :user, JetzySchema.Types.User.Reference
    field :name, :string
    field :referral_code, :string
    field :email, :string
    field :strategy, :string
    field :source, :string

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
