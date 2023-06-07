#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Moderation.Status.Enum do
  @vsn 1.0
  @nmid_index 258
  @sref "moderation-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        user_flagged: 1,
        auto_flagged: 2,
        under_review: 3,
        accepted: 4,
        rejected: 5,
      ]
end
