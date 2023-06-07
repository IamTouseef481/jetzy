defmodule Data.Schema.User.Subscription do
  @moduledoc """
    The schema for User.Subscription
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,

               user_id: Ecto.UUID.t, # Denormalized
               subscription_id: Ecto.UUID.t,
   
               status: :pending| :active | :paused | :delinquent | :cancelled | :expired | :replaced, # Denormalized Field
  
               subscription_start: DateTime.t,
               subscription_end: DateTime.t | nil,

               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    user_id
    subscription_id
    status
    subscription_start
    subscription_end
    inserted_at
    updated_at
    deleted_at
  |a
  
  schema "user_subscription" do
    belongs_to :user, Data.Schema.User
    belongs_to :subscription, Data.Schema.Subscription
    field :status, Ecto.Enum, values: [pending:  0, active: 1, paused: 2, delinquent: 3, cancelled: 4, expired: 5, replaced: 6]
    field :subscription_start, :utc_datetime
    field :subscription_end, :utc_datetime
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
  end
  
  @nmid_index 605
  use Data.Schema.TanbitsEntity, sref: "t-subscription"
end