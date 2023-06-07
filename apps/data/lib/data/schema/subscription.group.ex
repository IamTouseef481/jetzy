defmodule Data.Schema.Subscription.Group do
  @moduledoc """
    The schema for Subscription.Group
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               name: String.t,
               handle: String.t,
               description: String.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    handle
    description
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    handle
    description
    updated_at
  |a
  
  schema "subscription_group" do
    field :name, :string
    field :handle, :string
    field :description, :string
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 610
  use Data.Schema.TanbitsEntity, sref: "t-subscription-group"
end