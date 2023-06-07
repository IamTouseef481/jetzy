defmodule Data.Schema.SysDiagram do
  @moduledoc """
    The schema for Sys diagram
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        definition: String.t | nil,
        name: String.t | nil,
        principal_id: integer,
        diagram_id: integer,
        version: integer
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    name
    principal_id
    diagram_id
    version
    definition
    id
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "sys_diagrams" do
    field :definition, :string
    field :name, :string
    field :principal_id, :integer
    field :diagram_id, :integer
    field :version, :integer


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 545
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
