#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Degree.Status.Enum do
  @vsn 1.0
  @nmid_index 226
  @sref "degree-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        completed: 1,
        in_progress: 2,
        unfinished: 3
      ]
end
