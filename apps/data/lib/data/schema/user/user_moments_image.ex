defmodule Data.Schema.UserMomentsImage do
  @moduledoc """
    The schema for User moments image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        compressed_image_name: String.t | nil,
        blur_hash: String.t | nil,
        is_current: boolean,
        is_deleted: boolean,
        is_image_sync: boolean,
        image_identifier: integer | nil,
        large_image_name: String.t | nil,
        medium_image_name: String.t | nil,
        small_image_name: String.t | nil,
        thumb_image_name: String.t | nil,
        moment_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    moment_id
    thumb_image_name
    small_image_name
    medium_image_name
    large_image_name
    compressed_image_name
    is_deleted
    is_image_sync
    is_current
    inserted_at
    updated_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_moments_images" do
    field :compressed_image_name, :string
    field :blur_hash
    field :is_current, :boolean
    field :is_deleted, :boolean
    field :is_image_sync, :boolean
    field :large_image_name, :string
    field :medium_image_name, :string
    field :small_image_name, :string
    field :thumb_image_name, :string
    field :image_identifier, :integer
    belongs_to :moment, Data.Schema.UserMoment

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:moment_id)
  end

  @nmid_index 571
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
