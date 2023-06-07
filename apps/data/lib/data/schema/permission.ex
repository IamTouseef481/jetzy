defmodule Data.Schema.Permission do
  @moduledoc """
    The schema for Permission
  """
  use Data.Schema

#  @derive Noizu.ERP
#  @derive Tanbits.Shim
#  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
     id: binary,
     permission: integer,
     role_id: String.t(),
     resource_id: String.t()
 }


  @required_fields ~w|
    permission
    role_id
    resource_id
  |a

  @optional_fields ~w|
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "permissions" do
    field :permission, :integer
    field :role_id, :string
    field :resource_id, :string
#    belongs_to(:role, Data.Schema.Role, type: :string)
#    belongs_to(:resource, Data.Schema.Resource, type: :string)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

#  @nmid_index 526
#  use Data.Schema.TanbitsEntity, sref: "t-user"
end
