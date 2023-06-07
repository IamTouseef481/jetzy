#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Moderation.Resolution.Enum do
  @vsn 1.0
  @nmid_index 257
  @sref "moderation-resolution"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        accepted: 1,
        rejected: 2,
        flagged: 3,
        administrative_action: 4,
      ]
end
