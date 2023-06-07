defmodule Data.Schema.RewardManager do
  @moduledoc """
    The schema for Reward manager
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        activity: String.t | nil,
        activity_type: atom,
        is_deleted: boolean,
        winning_point: float,

    }

    @activity_type_mapping [
      started_new_group_conversation: 0,
      promote_on_facebook: 1,
      post_a_moment: 2,
      chat_session_with_friends: 3,
      refer_a_friend: 4,
      sign_up_through_referral: 5,
      redemption: 6,
      other: 7,
      early_sign_up: 8,
      friending_exisiting_app_users: 9,
      click_reward_links: 10,
      share_image_on_fb_or_ig_or_twitter_and_auto_tag_jetzy: 11,
      bonus_for_signing_10_friends: 12,
      bonus_for_signing_100_friends: 13,
      bonus_for_signing_1000_friends: 14,
      bonus_for_first_500_chats: 15,
      bonus_for_first_5000_chats: 16,
      bonus_for_first_500_photos: 17,
      bonus_for_first_2000_photos: 18,
      sign_up_3000: 19,
      non_admin_invite_signupthroughreferal: 20,
      admin_invite_signupthroughreferal: 21,
      offer_redeem_request_declined: 22,
      made_a_post: 23,
      added_a_photo: 24,
      commented_on_a_post: 25,
      tagged_by_someone: 26,
      deleted_a_photo: 27,
      deleted_a_comment: 28,
      untagged_by_someone: 29,
      added_favorite_restaurant: 30,
      removed_favorite_restaurant: 31,
      deleted_a_post: 32,
      tagged_someone: 33,
      untagged_someone: 34,
      post_liked: 35,
      create_a_event: 36,
      sign_in: 37,
      started_new_conversation_with_user: 38,
      sign_up_1000: 39,
      
    ]

  @required_fields ~w|

  |a

  @optional_fields ~w|
    id
    deleted_at
    winning_point
    activity
    is_deleted
    activity_type
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "reward_managers" do
    field :activity, :string
    field :activity_type, Ecto.Enum, values: @activity_type_mapping
    field :is_deleted, :boolean
    field :winning_point, :float


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> unique_constraint([:activity_type])
    |> validate_required(@required_fields)
  end

  @nmid_index 533
  use Data.Schema.TanbitsEntity, sref: "t-reward-manager"
end
