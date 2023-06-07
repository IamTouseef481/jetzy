defmodule Data.Schema.JetzyTestSept do
  @moduledoc """
    The schema for Jetzy test sept
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        address: String.t | nil,
        city: String.t | nil,
        first_name: String.t | nil,
        last_name: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    first_name
    last_name
    address
    city
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "jetzy_test_septs" do
    field :address, :string
    field :city, :string
    field :first_name, :string
    field :last_name, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  @nmid_index 597
  use Data.Schema.TanbitsEntity, sref: "t-user"

end
