defmodule Data.Schema.UserEventCommentLike do
  @moduledoc """
    The schema for likes of Event Comments or their replies
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               room_message_id: integer,
               liked_by_id: binary,
             }

  @required_fields ~w|
    room_message_id
    liked_by_id
  |a

  @optional_fields ~w|

  inserted_at
  updated_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_event_comment_likes" do
    belongs_to :liked_by, Data.Schema.User
    belongs_to :room_message, Data.Schema.RoomMessage

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end


  @nmid_index 554
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
