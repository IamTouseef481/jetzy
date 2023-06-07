defmodule Data.Schema.ReportSource do
  @moduledoc """
    The schema for Report source
  """
  use Data.Schema

  @type t :: %__MODULE__{
        id: String.t(),
        deleted_at: DateTime.t | nil,
        is_deleted: boolean,
        name: String.t() | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    id
    deleted_at
    name
    is_deleted
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields

  @primary_key false
  schema "report_sources" do
    field :id, :string, primary_key: true
    field :is_deleted, :boolean
    field :name, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

end
