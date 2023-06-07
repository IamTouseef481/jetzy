defmodule Data.Schema.RoomMessage do
  @moduledoc """
    The schema for Room message
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
          id: binary,
          message: String.t() | nil,
          sender_id: binary,
          room_id: binary,
          callback_verification: String.t() | nil,
          parent_id: binary,
        }

  @required_fields ~w|
    sender_id
    room_id

    |a

  @optional_fields ~w|
      message
      parent_id
      inserted_at
      callback_verification
      updated_at
    |a

  @all_fields @required_fields ++ @optional_fields

  schema "room_messages" do
    field(:message, :string)
    field(:callback_verification, :string)

    belongs_to(:sender, Data.Schema.User)
    belongs_to(:room, Data.Schema.Room)
    belongs_to(:parent, Data.Schema.RoomMessage)
    has_many :message_images, Data.Schema.RoomMessageImage, on_replace: :delete
    has_many :replies, Data.Schema.RoomMessage, on_replace: :delete, foreign_key: :parent_id
    has_one :room_message_meta, Data.Schema.RoomMessageMeta, on_replace: :delete

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 537
  use Data.Schema.TanbitsEntity, sref: "t-room-msg"

end
