defmodule Data.Schema.UserInterestTagged do
  @moduledoc """
    The schema for User interest tagged
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        contact_number: String.t | nil,
        emails: String.t | nil,
        flag: boolean,
        is_active: boolean,
        is_admin: boolean,
        interest_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    emails
    contact_number
    interest_id
    is_active
    is_admin
    flag
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_interests_tagged" do
    field :contact_number, :string
    field :emails, :string
    field :flag, :boolean
    field :is_active, :boolean
    field :is_admin, :boolean

    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 567
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
