defmodule Data.Schema.UserInquiry do
  @moduledoc """
    The schema for User inquiry
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        bcc_address: String.t | nil,
        cc_address: String.t | nil,
        created_date: :date,
        description: String.t | nil,
        last_modified_date: :date,
        subject: String.t | nil,
        to_address: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    to_address
    cc_address
    bcc_address
    subject
    description
    created_date
    last_modified_date
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_inquiries" do
    field :bcc_address, :string
    field :cc_address, :string
    field :created_date, :date
    field :description, :string
    field :last_modified_date, :date
    field :subject, :string
    field :to_address, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 565
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
