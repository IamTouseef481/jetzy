defmodule Data.Schema.Subscription.Feature do
  @moduledoc """
    The schema for group of feature grants. Such as default features granted to unverified users.
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               subscription_id: binary,
               feature_id: binary,
               grant_type: atom,
               monthly_quota: integer,
               daily_quota: integer,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }
  
  @all_fields ~w|
    subscription_id
    feature_id
    grant_type
    monthly_quota
    daily_quota
    inserted_at
    updated_at
    deleted_at
  |a
  
  
  @required_fields ~w|
    subscription_id
    feature_id
    grant_type
    updated_at
  |a
  
  schema "subscription_feature" do
    belongs_to :subscription, Data.Schema.Subscription
    belongs_to :feature, Data.Schema.Feature
    field :grant_type, Ecto.Enum, values: [:unlimited, :revoked, :quota]
    field :monthly_quota, :integer
    field :daily_quota, :integer
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 612
  use Data.Schema.TanbitsEntity, sref: "t-subscription-feature"
end