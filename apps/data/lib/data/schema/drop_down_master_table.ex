defmodule Data.Schema.DropDownMasterTable do
  @moduledoc """
    The schema for Drop down master table
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_child_control: boolean,
        name: String.t | nil,
        section: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    name
    is_child_control
    section
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "drop_down_master_tables" do
    field :is_child_control, :boolean
    field :name, :string
    field :section, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 512
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
