defmodule Data.Schema.UserSetting do
  @moduledoc """
    The schema for UserSettings
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
    id: binary,

    user_id: binary,
    is_push_notification: boolean,
    is_groupchat_enable: boolean,
    is_show_on_profile: boolean,
    is_moments_enable: boolean,
    is_profile_image_sync: boolean,
    is_enable_chat: boolean,
    is_info: boolean,
    user_invite_type: integer,
    un_subscribe: boolean,
    is_follow_public: boolean,
    is_show_followings: boolean

  }

  @required_fields ~w|
    user_id
  |a

  @optional_fields ~w|

  is_push_notification
  is_show_on_profile
  is_moments_enable
  is_profile_image_sync
  is_enable_chat
  is_groupchat_enable
  is_info
  user_invite_type
  un_subscribe
  is_follow_public
  is_show_followings

    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "user_settings" do

    field :is_show_on_profile, :boolean
    field :is_push_notification, :boolean
    field :is_enable_chat, :boolean
    field :is_groupchat_enable, :boolean
    field :is_moments_enable, :boolean
    field :is_profile_image_sync, :boolean
    field :is_info, :boolean
    field :un_subscribe, :boolean
    field :user_invite_type, :integer

    field :is_follow_public, :boolean #whether anyone can follow this user?
    field :is_show_followings, :boolean #whether anyone can see who this user is following to

    belongs_to :user, Data.Schema.User
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
#    |> unique_constraint(:email)
  end

  @nmid_index 586
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
