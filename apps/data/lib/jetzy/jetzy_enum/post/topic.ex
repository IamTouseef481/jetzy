#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Topic.Enum do
  @vsn 1.0
  @nmid_index 270
  @sref "post-topic"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        meet_for_coffee: 1,
        let_go_broadways: 2,
        jetzy_broadway: 3,
        going_for_a_hike: 4,
        skydiving: 5,
        meet_for_a_drink: 6,
        local_secret_gems: 7,
        chilling_in_tribeca: 8,
        lets_go_wine_testing: 9,
        weekend_at_beach: 10,
        lets_have_a_coffee: 11,
        question: 12,
        share_information: 13,
        meet_up: 14,
        trending_now: 15,
        weekend_plans: 16,
        food_and_drink: 17,
        beer_and_wine: 18,
        shopping: 19,
        restaurant_recommendations: 20,
        runner: 21,
        beach_life: 22,
        music_scene: 23,
        nightlife: 24,
        fitness: 25,
        events_and_festivals: 26,
        sports: 27,
        culture_and_art: 28,
        wellness: 29,
        other: 30,
        outdoor_adventure: 31,
        test_123: 32,
        test_12345: 33,
        test: 34,
        first_test_topic1: 35,
        business_networking: 36,
      ]
end
