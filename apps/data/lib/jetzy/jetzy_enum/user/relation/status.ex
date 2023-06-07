
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Relation.Status.Enum do
  @vsn 1.0
  @nmid_index 294
  @sref "user-relation-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        active: 1,
        pending: 2,
        restricted: 3,
        deleted: 4,
        error: 5,
        degraded: 6,
        disabled: 7,
      ]
end
