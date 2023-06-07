#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Degree.Type.Enum do
  @vsn 1.0
  @nmid_index 227
  @sref "degree-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        associate: 1,
        bachelors: 2,
        masters: 3,
        doctorate: 4,
        certificate: 5
      ]
end
