defmodule Data.Schema.Room do
  @moduledoc """
    The schema for Room
  """
  use Data.Schema
  alias Data.Schema.RoomUser
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
          id: binary,
          room_type: String.t() | nil,
          deleted_by: binary,
          created_by: binary,
          image_name: String.t() | nil,
          image_identifier: integer | nil,
          small_image_name: String.t | nil,
          blur_hash: String.t() | nil,
          shareable_link: String.t | nil
        }

  @required_fields ~w|
        room_type

    |a

  @optional_fields ~w|
     is_private
     group_name
     small_image_name
     inserted_at
     updated_at
     deleted_by
     image_name
     last_message_at
     blur_hash
     shareable_link
     image_identifier
    |a

  @all_fields @required_fields ++ @optional_fields

  schema "rooms" do
    field(:room_type, :string)
    field(:is_private, :boolean)
    field(:group_name, :string)
    field(:deleted_by, Ecto.UUID)
    field(:created_by, Ecto.UUID)
    field(:image_name, :string)
    field(:last_message_at, :utc_datetime)
    field(:blur_hash, :string)
    field(:small_image_name, :string)
    field(:shareable_link, :string)
    field :image_identifier, :integer
    has_many :messages, Data.Schema.RoomMessage, on_replace: :delete
    many_to_many :users, Data.Schema.User, join_through: RoomUser, on_replace: :delete
    has_one :user_event, Data.Schema.UserEvent, on_replace: :delete, foreign_key: :group_chat_room_id
    has_many :room_referral_code, Data.Schema.RoomReferralCode
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 536
  use Data.Schema.TanbitsEntity, sref: "t-room"

end
