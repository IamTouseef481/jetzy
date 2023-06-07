defmodule Data.Schema.UserCountry do
  @moduledoc """
    The schema for User country
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        city: String.t | nil,
        country: String.t | nil,
        from_date: :date,
        to_date: :date,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    city
    country
    from_date
    to_date
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_countries" do
    field :city, :string
    field :country, :string
    field :from_date, :date
    field :to_date, :date

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 601
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
