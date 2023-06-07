defmodule Data.Schema.RegisterUserWithPrivateInterest do
  @moduledoc """
    The schema for Register user with private interest
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        emails: String.t | nil,
        is_deleted: boolean,
        interest_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    emails
    interest_id
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "register_user_with_private_interests" do
    field :emails, :string
    field :is_deleted, :boolean

    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 529
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
