#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Offer.Activity.Type.Enum do
  @vsn 1.0
  @nmid_index 263
  @sref "offer-activity-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        other: 0,
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
        sign_up: 19,
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
        untagged_someone: 34
      ]
end
