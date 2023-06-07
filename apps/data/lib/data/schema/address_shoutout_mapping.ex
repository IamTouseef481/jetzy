defmodule Data.Schema.AddressShoutoutMapping do
  @moduledoc """
    The schema for Address shoutout mapping
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_old_moment: boolean,
        address_component_id: binary,
        shoutout_id: binary,
    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    address_component_id
    shoutout_id
    is_old_moment
    inserted_at
    updated_at
    
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "address_shoutout_mappings" do
    field :is_old_moment, :boolean

    belongs_to :address_component, Data.Schema.AddressComponent
    belongs_to :shoutout, Data.Schema.UserShoutout

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:address_component_id)
    |> foreign_key_constraint(:shoutout_id)
  end

  @nmid_index 502
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
