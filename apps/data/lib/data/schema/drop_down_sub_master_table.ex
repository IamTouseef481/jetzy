defmodule Data.Schema.DropDownSubMasterTable do
  @moduledoc """
    The schema for Drop down sub master table
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        name: String.t | nil,
        sort_order: integer,
        status: binary,
        drop_down_master_table_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    name
    sort_order
    status_id
    drop_down_master_table_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "drop_down_sub_master_tables" do
    field :name, :string
    field :sort_order, :integer

    belongs_to :status, Data.Schema.Status
    belongs_to :drop_down_master_table, Data.Schema.DropDownMasterTable

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 513
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
