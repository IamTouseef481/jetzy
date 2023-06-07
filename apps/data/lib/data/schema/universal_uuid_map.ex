defmodule Data.Schema.UniversalUuidMap do
  @moduledoc """
    The schema for Universal UUID Map
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
    id: binary,
    int_id: integer,
    generated_id: binary,
    table_name: String.t,
    status: String.t,
             }

  @required_fields ~w|
    int_id
    table_name
    generated_id
  |a

  @optional_fields ~w|
    status
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields
  schema "universal_uuid_map" do
    field :int_id, :integer
    field :generated_id, :binary
    field :table_name, :string
    field :status, :string
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 547
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
