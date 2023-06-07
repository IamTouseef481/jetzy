#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Group.Permission.Enum do
  @vsn 1.0
  @nmid_index 242
  @sref "group-permission"
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
