defmodule Data.Schema.Package do
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
               handle: String.t,
               description: String.t,
               definition: Map.t,
               enabled: boolean,
               reoccurrence: atom,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    handle
    description
    definition
    enabled
    reoccurrence
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    handle
    description
    definition
    enabled
    reoccurrence
    inserted_at
    updated_at
  |a
  
  schema "package" do
    field :name, :string
    field :handle, :string
    field :description, :string
    field :definition, :map
    field :enabled, :boolean
    field :reoccurrence, Ecto.Enum, values: [none: 0, monthly: 1, annual: 2]
    timestamp()
    has_many :subscriptions, Data.Schema.Package.Subscription, where: [deleted_at: nil], on_replace: :delete
    has_many :items, Data.Schema.Package.Item, where: [deleted_at: nil], on_replace: :delete
    has_many :pricing, Data.Schema.Package.Price, where: [deleted_at: nil], on_replace: :delete
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 613
  use Data.Schema.TanbitsEntity, sref: "t-package"
end