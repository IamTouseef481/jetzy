#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Relation.Group.Type.Enum do
  @vsn 1.0
  @nmid_index 293
  @sref "user-relation-group-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      versioning: Jetzy.UserVersionedString.TypeHandler,
      values: [
        none: 0,
        best_friends: 1,
        coworkers: 2,
        family: 3,
      ]
end
