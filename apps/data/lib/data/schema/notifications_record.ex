defmodule Data.Schema.NotificationsRecord do
  @moduledoc """
    The schema for Notifications record
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        chat_message_type: String.t | nil,
        description: String.t | nil,
        friend_activity_type: String.t | nil,
#        group_id: String.t | nil,
        is_deleted: boolean,
        moment_message_type: String.t | nil,
        pending_friend_request: String.t | nil,
        type: String.t | nil,
        sender_id: binary,
        receiver_id: binary,
#        moment_id: binary,
#        shoutout_id: binary,
#        comment_id: binary,
#        comment_source_id: binary,
        is_read: binary,
        resource_id: binary | nil,
        is_opened: boolean
     }

  @required_fields ~w|
    
  |a
  #    moment_id
  #    shoutout_id
  #    comment_id
  #    comment_source_id
  @optional_fields ~w|
    deleted_at
    sender_id
    receiver_id
    description
    type
    friend_activity_type
    pending_friend_request
    chat_message_type
    moment_message_type
    resource_id
    is_deleted
    is_read
    inserted_at
    updated_at
    is_opened
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "notification_records" do
    field :chat_message_type, :string
    field :description, :string
    field :friend_activity_type, :string
#    field :group_id, :string
    field :is_deleted, :boolean
    field :is_read, :boolean
    field :moment_message_type, :string
    field :pending_friend_request, :string
    field :type, :string
    field :resource_id, Ecto.UUID
    field :is_opened, :boolean

    belongs_to :sender, Data.Schema.User
    belongs_to :receiver, Data.Schema.User
#    belongs_to :moment, Data.Schema.UserMoment
#    belongs_to :shoutout, Data.Schema.UserShoutout
#    belongs_to :comment, Data.Schema.Comment
#    belongs_to :comment_source, Data.Schema.CommentSource

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 524
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
