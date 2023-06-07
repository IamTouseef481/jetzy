#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Permission.Enum do
  @vsn 1.0
  @nmid_index 268
  @sref "permission"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        read: 1,
        write: 2,
        edit: 3,
        delete: 4,
        manage: 5,
      ]
end
