defmodule Data.Schema.UserFavoriteType do
  @moduledoc """
    The schema for User favorite
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: String.t,
               deleted_at: DateTime.t | nil,
               description: String.t | nil,
             }

  @required_fields ~w|
    id
  |a

  @optional_fields ~w|
    deleted_at
    description
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields
  @primary_key false
  schema "user_favorite_types" do
    field :id, :string, primary_key: true
    field :description, :string
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)

  end

  @nmid_index 558
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
