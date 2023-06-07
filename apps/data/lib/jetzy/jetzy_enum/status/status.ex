#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Status.Enum do
  @vsn 1.0
  @nmid_index 286
  @sref "status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        active: 1,
        pending: 2,
        restricted: 3,
        deleted: 4,
        error: 5,
        degraded: 6,
        disabled: 7,
        sent: 8,
        failed: 9,
        bounce: 10,
        linked: 11,
        inactive: 12,
        unviewed: 13,
        viewed: 14,
        cleared: 15,
      ]
end
