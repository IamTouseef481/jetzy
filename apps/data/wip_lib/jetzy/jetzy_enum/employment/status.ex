#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Employment.Status.Enum do
  @vsn 1.0
  @nmid_index 231
  @sref "employment-status"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        current: 1,
        future: 2,
        past: 3
      ]
end
