#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Redeem.Type.Enum do
  @vsn 1.0
  @nmid_index 275
  @sref "redeem-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        standard: 1,
        multi_redeem: 2,
      ]
end
