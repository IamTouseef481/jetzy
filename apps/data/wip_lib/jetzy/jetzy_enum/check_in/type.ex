#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CheckIn.Type.Enum do
  @vsn 1.0
  @nmid_index 213
  @sref "check-in-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        other: 0,
        visiting: 1,
        dinning: 2
      ],
      default: :other
end
