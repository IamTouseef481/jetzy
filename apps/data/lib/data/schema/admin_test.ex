defmodule Data.Schema.AdminTest do
  @moduledoc """
    The schema for Admin test
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        city: String.t | nil,
        first_name: String.t | nil,
        is_super_admin: boolean,
        email: String.t | nil,
        last_name: String.t | nil,
        password: String.t | nil,
        role_id: String.t,
        
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    first_name
    last_name
    city
    password
    role_id
    is_super_admin
    email
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "admin_tests" do
    field :city, :string
    field :first_name, :string
    field :is_super_admin, :boolean
    field :last_name, :string
    field :password, :string
    field :role_id, :string
    field :email, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 504
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
