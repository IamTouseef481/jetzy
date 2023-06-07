#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.System.Enum do
  @vsn 1.0
  @nmid_index 288
  @sref "system"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        auto_moderation: 1,
        indexing: 2,
        legacy: 3,
        cron: 4,
      ]
end
