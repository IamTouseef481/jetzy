defmodule Data.Schema.Package.Item do
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
               quantity: integer,
               package_id: binary,
               item_id: binary,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    description
    quantity
    package_id
    item_id
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    description
    quantity
    package_id
    item_id
    inserted_at
    updated_at
  |a
  
  schema "package_item" do
    field :name, :string
    field :description, :string
    field :quantity, :integer
    belongs_to :package, Data.Schema.Package
    belongs_to :item, Data.Schema.Item
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 614
  use Data.Schema.TanbitsEntity, sref: "t-package-item"
end