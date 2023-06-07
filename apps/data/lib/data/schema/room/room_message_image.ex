defmodule Data.Schema.RoomMessageImage do
  @moduledoc """
    The schema for Room message images
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
          id: binary,
          image: String.t() | nil,
          image_identifier: integer | nil,
          small_image: String.t | nil,
          blur_hash: String.t | nil,
          room_message_id: binary,
        }

  @required_fields ~w|
    room_message_id

      |a

  @optional_fields ~w|
        image
        small_image
        inserted_at
        updated_at
        blur_hash
        image_identifier
      |a

  @all_fields @required_fields ++ @optional_fields

  schema "room_message_images" do
    field(:image, :string)
    field(:small_image, :string)
    field(:blur_hash, :string)
    field :image_identifier, :integer
    belongs_to(:room_message, Data.Schema.RoomMessage)

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 538
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
