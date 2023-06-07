defmodule Data.Schema.Package.Price do
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
               definition: Map.t,
               package_id: binary,
               price: float,
               region: String.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    description
    definition
    package_id
    price
    region
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    description
    definition
    package_id
    price
    region
    inserted_at
    updated_at
  |a
  
  schema "package_price" do
    field :name, :string
    field :description, :string
    field :definition, :map
    field :price, :float
    field :region, :string
    belongs_to :package, Data.Schema.Package
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 615
  use Data.Schema.TanbitsEntity, sref: "t-package-price"
end