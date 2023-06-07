defmodule Data.Schema.UserApprovalLog do
  @moduledoc """
    Jetzy Exclusive Change Log
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: String.t,
               user_id: String.t,
               approval_source: atom,
               approval_status: atom,
               updated_by_user_id: String.t,
               remark: String.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t | nil,
             }

  @required_fields ~w|
  |a

  @optional_fields ~w|
    user_id
    approval_source
    approval_status
    updated_by_user_id
    remark
    inserted_at
    updated_at
    deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields
  
  schema "user_approval_log" do
    belongs_to :user, Data.Schema.User
    field :approval_source, Ecto.Enum, values: [:system, :legacy, :admin, :user, :group, :auto], default: :system, null: false
    field :approval_status, Ecto.Enum, values: [:approved, :pending, :paused, :denied, :review], null: false
    belongs_to :updated_by_user, Data.Schema.User
    field :remark, :string, null: true
    timestamp()
  end


  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 1094
  use Data.Schema.TanbitsEntity, sref: "t-user-approval-log"

end
