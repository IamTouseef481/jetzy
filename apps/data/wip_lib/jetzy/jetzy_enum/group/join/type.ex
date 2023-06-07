#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Group.Join.Type.Enum do
  @vsn 1.0
  @nmid_index 240
  @sref "group-join-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
      ]
end
