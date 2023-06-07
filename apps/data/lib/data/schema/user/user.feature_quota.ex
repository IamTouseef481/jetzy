defmodule Data.Schema.User.FeatureQuota do
  @moduledoc """
    The schema for group of feature grants. Such as default features granted to unverified users.
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               user_id: Ecto.UUID.t,
               cached_at: DateTime.t,
               definition: Map.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    user_id
    cached_at
    definition
    inserted_at
    updated_at
    deleted_at
  |a
  
  schema "user_feature_quota" do
    belongs_to :user, Data.Schema.User
    field :cached_at, :utc_datetime
    field :definition, :map
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
  end
  
  @nmid_index 609
  use Data.Schema.TanbitsEntity, sref: "t-user-feature-quota"
end