defmodule Data.Schema.UserMoment do
  @moduledoc """
    The schema for User moment
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        api_version: integer,
        is_deleted: boolean,
        is_moment_image_sync: boolean,
        is_shared: boolean,
        moment_country: String.t | nil,
        moment_city: String.t | nil,
        moment_description: String.t | nil,
        moment_latitude: String.t | nil,
        moment_location: String.t | nil,
        moment_longitude: String.t | nil,
        moment_title: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    moment_title
    moment_description
    moment_country
    moment_city
    moment_location
    moment_latitude
    moment_longitude
    user_id
    is_shared
    is_deleted
    is_moment_image_sync
    api_version
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_moments" do
    field :api_version, :integer
    field :is_deleted, :boolean
    field :is_moment_image_sync, :boolean
    field :is_shared, :boolean
    field :moment_country, :string
    field :moment_city, :string
    field :moment_description, :string
    field :moment_latitude, :string
    field :moment_location, :string
    field :moment_longitude, :string
    field :moment_title, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 569
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
