defmodule Data.Schema.Splash do
  @moduledoc """
    The schema for Splash
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        city: String.t | nil,
        email: String.t | nil,
        is_deleted: boolean,
        name: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    name
    email
    is_deleted
    city
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "splashs" do
    field :city, :string
    field :email, :string
    field :is_deleted, :boolean
    field :name, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 543
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
