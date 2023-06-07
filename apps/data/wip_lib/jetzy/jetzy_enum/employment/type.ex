#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Employment.Type.Enum do
  @vsn 1.0
  @nmid_index 232
  @sref "employment-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        full_time: 1,
        part_time: 2,
        volunteer: 3,
        intern: 4,
        owner: 5,
        self_employed: 6
      ]
end
