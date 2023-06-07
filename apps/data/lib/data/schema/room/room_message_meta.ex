defmodule Data.Schema.RoomMessageMeta do
  @moduledoc """
    The schema for Room Messages Meta
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
     id: binary,
     room_message_id: binary,
     no_of_likes: integer,
     room_id: binary,
     user_id: binary,
     is_read: boolean,
     favourite: boolean,
    is_deleted: boolean
   }
# No of likes in required field according to previous schema structure
  @required_fields ~w|
    room_message_id
    user_id
    room_id
  |a


  @optional_fields ~w|
    inserted_at
    updated_at
    is_read
    favourite
    no_of_likes
    is_deleted
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "room_messages_meta" do
    field :no_of_likes, :integer, default: 0
    field :favourite, :boolean
    field :is_read, :boolean
    field :is_deleted, :boolean
    belongs_to :room_message, Data.Schema.RoomMessage
    belongs_to :room, Data.Schema.Room
    belongs_to :user, Data.Schema.User


    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :room_message_id])
  end


  @nmid_index 539
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
