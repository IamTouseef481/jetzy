defmodule Data.Schema.UserRole do
  @moduledoc """
    The schema for User Role
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
   id: binary,
   role_id: String.t(),
   user_id: binary
 }


  @all_fields ~w|
    role_id
    user_id
    inserted_at
    updated_at
  |a

  schema "user_roles" do
    belongs_to(:role, Data.Schema.Role, type: :string)
    belongs_to(:user, Data.Schema.User)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
  end

  @nmid_index 584
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
