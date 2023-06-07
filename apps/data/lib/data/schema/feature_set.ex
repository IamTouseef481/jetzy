defmodule Data.Schema.FeatureSet do
  @moduledoc """
    The schema for group of feature grants. Such as default features granted to unverified users.
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               name: String.t,
               handle: String.t,
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

  
  schema "feature_set" do
    field :name, :string
    field :handle, :string
    field :description, :string
    has_many :features, Data.Schema.FeatureSetFeature, where: [deleted_at: nil], on_replace: :delete
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 608
  use Data.Schema.TanbitsEntity, sref: "t-feature-set"
end