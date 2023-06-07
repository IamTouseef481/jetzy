defmodule Data.Schema.ShoutoutType do
  @moduledoc """
    The schema for Shoutout type
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_deleted: boolean,
        name: String.t | nil,
        sort_order: integer,
        status: integer,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    name
    sort_order
    is_deleted
    status
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "shoutout_types" do
    field :is_deleted, :boolean
    field :name, :string
    field :sort_order, :integer
    field :status, :integer


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 542
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
