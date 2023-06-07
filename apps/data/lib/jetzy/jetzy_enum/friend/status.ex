#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Friend.Status.Enum do
  @vsn 1.0
  @nmid_index 236
  @sref "friend-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        pending: 0,
        accepted: 1,
        rejected: 2,
        ignored: 3,
        inactive: 4,
        active: 5,
      ],
      default: :pending
end
