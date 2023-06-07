defmodule Data.Schema.UserReport do
  @moduledoc """
    The schema for User report
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        description: String.t | nil,
        is_deleted: boolean,
        report_type: String.t | nil,
        reported_id: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    reported_id
    report_type
    description
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_reports" do
    field :description, :string
    field :is_deleted, :boolean
    field :report_type, :string
    field :reported_id, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 582
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
