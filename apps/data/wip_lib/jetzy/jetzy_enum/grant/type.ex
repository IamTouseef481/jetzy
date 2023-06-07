#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Grant.Type.Enum do
  @vsn 1.0
  @nmid_index 238
  @sref "grant-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        system: 1,
        admin: 2,
        user: 3,
        group: 4
      ]
end
