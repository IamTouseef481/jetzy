defmodule Data.Schema.OTPToken do
  @moduledoc """
    The schema for OTP Tokens
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary(),
               purpose: String.t(),
               otp: integer,
               last_forget_password_at: DateTime.t(),
               last_otp_sent_at: DateTime.t(),
               user_id: binary
             }

  @required_fields ~w|
    user_id
  |a

  @optional_fields ~w|
    purpose
    otp
    last_forget_password_at
    last_otp_sent_at
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "otp_tokens" do
    field :last_forget_password_at, :utc_datetime
    field :last_otp_sent_at, :utc_datetime
    field :otp, :integer
    field :purpose, :string

    belongs_to :user, Data.Schema.User
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 525
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
