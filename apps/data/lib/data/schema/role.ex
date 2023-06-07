defmodule Data.Schema.Role do

  @moduledoc """
    The schema for Roles
  """
  use Data.Schema

  @type t :: %__MODULE__{
   id: String.t(),
   name: String.t(),
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
  schema "roles" do
    field :id, :string, primary_key: true
    field :name, :string

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

end
