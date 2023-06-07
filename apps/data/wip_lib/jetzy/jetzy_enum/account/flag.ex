#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Account.Flag.Enum do
  @vsn 1.0
  @nmid_index 201
  @sref "account-flag"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        community: 1,
        abusive: 2,
        fake: 3,
        atuo: 4
      ]
end
