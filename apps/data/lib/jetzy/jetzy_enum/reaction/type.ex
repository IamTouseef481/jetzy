#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Reaction.Type.Enum do
  @vsn 1.0
  @nmid_index 274
  @sref "reaction-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        like: 1,
        dislike: 2,
        heart: 3,
        angry: 4,
        sad: 5,
        laugh: 6,
        confused: 7,
        comfort: 8,
      ]
end
