defmodule Data.Schema.Subscription do
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
               group_id: Ecto.UUID.t,
               description: String.t,
               enabled: boolean,
               definition: Map.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    handle
    group_id
    description
    enabled
    definition
    inserted_at
    updated_at
    deleted_at
  |a


  @required_fields ~w|
    name
    handle
    group_id
    description
    enabled
    definition
    inserted_at
    updated_at
  |a
  
  schema "subscription" do
    field :name, :string
    field :handle, :string
    belongs_to :group, Data.Schema.Subscription.Group

    field :description, :string
    field :enabled, :boolean
    field :definition, :map
    timestamp()
    has_many :features, Data.Schema.Subscription.Feature, where: [deleted_at: nil], on_replace: :delete
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 605
  use Data.Schema.TanbitsEntity, sref: "t-subscription"
end