defmodule Data.Schema.UserImage do
  @moduledoc """
    The schema for User image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        images: String.t | nil,
        image_identifier: integer | nil,
        blur_hash: String.t | nil,
        small_images: String.t | nil,
        is_deleted: boolean,
        order_number: integer,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    images
    small_images
    order_number
    is_deleted
    inserted_at
    updated_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_images" do
    field :images, :string
    field :is_deleted, :boolean
    field :order_number, :integer
    field :blur_hash, :string
    field :small_images, :string
    field :image_identifier, :integer
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 564
  use Data.Schema.TanbitsEntity, sref: "t-user-image"
end


