defmodule Data.Schema.AddressMomentMapping do
  @moduledoc """
    The schema for Address moment mapping
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        api_version: String.t | nil,
        is_new: boolean,
        address_component_id: binary,
        moment_id: binary,

    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    address_component_id
    moment_id
    api_version
    is_new
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "address_moment_mappings" do
    field :api_version, :string
    field :is_new, :boolean

    belongs_to :address_component, Data.Schema.AddressComponent
    belongs_to :moment, Data.Schema.UserMoment

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:address_component_id)
    |> foreign_key_constraint(:moment_id)
  end

  @nmid_index 501
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
