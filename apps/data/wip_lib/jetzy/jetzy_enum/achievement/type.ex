#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Achievement.Type.Enum do
  @vsn 1.0
  @nmid_index 202
  @sref "achievement-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        full_profile: 1,
        select: 2,
        experience: 3,
        globetrotter: 4,
        community_helper: 5,
        top_post: 6
      ]
end
