defmodule Data.Schema.UserDeletionLog do
  @moduledoc """
    The schema for User Deletion Log
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               event: String.t | nil,
               error: String.t | nil,
               status: String.t | nil,
               deleted_by_user: binary,
               deleted_user: binary,
             }

  @required_fields ~w|
    deleted_user_id
    status
  |a

  @optional_fields ~w|
    event
    error
    deleted_by_user_id
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_deletion_logs" do
    field :event, :string
    field :error, :string
    field :status, Ecto.Enum, values: [:completed, :not_completed]
    belongs_to :deleted_by_user, Data.Schema.User
    belongs_to :deleted_user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 382
  use Data.Schema.TanbitsEntity, sref: "t-user"
end