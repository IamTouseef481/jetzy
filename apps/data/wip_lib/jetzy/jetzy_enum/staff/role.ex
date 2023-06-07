#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Staff.Role.Enum do
  @vsn 1.0
  @nmid_index 284
  @sref "staff-role"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        limited: 1,
        partner: 2,
        reporting: 3,
        support: 4,
        admin: 5,
        super_admin: 6,
      ]
end
