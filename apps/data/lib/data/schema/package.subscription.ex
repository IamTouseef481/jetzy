defmodule Data.Schema.Package.Subscription do
  @moduledoc """
    The schema for Subscription
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               name: String.t,
               description: String.t,
               package_id: binary,
               subscription_id: binary,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    description
    package_id
    subscription_id
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    description
    package_id
    subscription_id
    inserted_at
    updated_at
  |a
  
  schema "package_subscription" do
    field :name, :string
    field :description, :string
    belongs_to :package, Data.Schema.Package
    belongs_to :subscription, Data.Schema.Subscription
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 616
  use Data.Schema.TanbitsEntity, sref: "t-package-subscription"
end