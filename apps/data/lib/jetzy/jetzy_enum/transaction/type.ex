#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Transaction.Type.Enum do
  @vsn 1.0
  @nmid_index 291
  @sref "transaction-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        event: 1,
        event_reverse: 2,
        redeem: 3,
        redeem_reverse: 4,
        admin: 5,
        admin_reverse: 6,
      ]
end
