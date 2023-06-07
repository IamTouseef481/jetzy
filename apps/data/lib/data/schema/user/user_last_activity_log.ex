defmodule Data.Schema.UserLastActivityLog do
  @moduledoc """
    The schema for User last activity log
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        api_version: integer,
        app_version: String.t | nil,
        device_id: String.t | nil,
        device_type: integer,
        end_point: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    end_point
    app_version
    api_version
    device_id
    device_type
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_last_activity_logs" do
    field :api_version, :integer
    field :app_version, :string
    field :device_id, :string
    field :device_type, :integer
    field :end_point, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 568
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
