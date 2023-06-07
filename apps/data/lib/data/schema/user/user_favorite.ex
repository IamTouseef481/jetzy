defmodule Data.Schema.UserFavorite do
  @moduledoc """
    The schema for User favorite
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               description: String.t | nil,
               name: String.t | nil,
               address: String.t | nil,
               image: String.t | nil,
               image_identifier: integer | nil,
               user_id: binary,
               small_image: String.t | nil,
               user_favorite_type_id: String.t | nil,
               blur_hash: String.t | nil,
               latitude: float,
               longitude: float
             }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    description
    name
    small_image
    address
    image
    user_id
    user_favorite_type_id
    inserted_at
    updated_at
    latitude
    longitude
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields
  schema "user_favorites" do
    field :name, :string
    field :description, :string
    field :address, :string
    field :image, :string
    field :latitude, :float
    field :longitude, :float
    field :small_image, :string
    field :blur_hash, :string
    field :image_identifier, :integer
    belongs_to  :user, Data.Schema.User
    belongs_to  :user_favorite_type, Data.Schema.UserFavoriteType, type: :string
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:user_favorite_type_id)
  end

  @nmid_index 557
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
