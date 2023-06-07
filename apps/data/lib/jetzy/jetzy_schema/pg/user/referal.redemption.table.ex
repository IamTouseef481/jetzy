defmodule JetzySchema.PG.User.Referral.Redemption.Table do
  @moduledoc """
  table defined in  liquibase/1.0/015_select.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_referral_code_redemption)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_referral_code_redemption" do
    field :user, JetzySchema.Types.Universal.Reference # denormalized from user_referral_code
    field :referred_user, JetzySchema.Types.Universal.Reference
    field :user_referral_code, JetzySchema.Types.User.Referral.Code.Reference
    field :entered_referral_on, :utc_datetime
    field :joined_select_on, :utc_datetime

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
