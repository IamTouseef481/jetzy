defmodule Data.Schema.UsersNotificationsRecord do
  @moduledoc """
    The schema for Users notifications record
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_deleted: boolean,
        is_enable: boolean,
        type: integer,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    type
    is_enable
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "users_notifications_records" do
    field :is_deleted, :boolean
    field :is_enable, :boolean
    field :type, :integer

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 594
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
