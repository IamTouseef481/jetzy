#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Transaction.Status.Enum do
  @vsn 1.0
  @nmid_index 336
  @sref "transaction-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        pending: 1,
        completed: 2,
        cancelled: 3
      ]
end
