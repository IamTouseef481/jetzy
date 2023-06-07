#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Session.Status.Enum do
  @vsn 1.0
  @nmid_index 279
  @sref "session-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        active: 1,
        expired: 2,
        locked: 3,
      ]
end
