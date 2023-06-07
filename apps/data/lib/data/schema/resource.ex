defmodule Data.Schema.Resource do
  @moduledoc """
    The schema for Resource
  """
  use Data.Schema
  @type t :: %__MODULE__{
     id: String.t(),
     name: String.t()
 }


  @required_fields ~w|
    id
    name
  |a

  @optional_fields ~w|
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  @primary_key false
  schema "resources" do
    field :id, :string, primary_key: true
    field :name, :string
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

end
