#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Group.Grant.Type.Enum do
  @vsn 1.0
  @nmid_index 239
  @sref "group-grant-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
      ]
end
