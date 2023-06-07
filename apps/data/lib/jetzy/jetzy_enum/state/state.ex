#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.State.Enum do
  @vsn 1.0
  @nmid_index 285
  @sref "state"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        enabled: 1,
        disabled: 2,
        deleted: 3,
        loading: 4,
        pending: 5,
        error: 6,
        failed: 7,
        review: 8,
      ]
end
