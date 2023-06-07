#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Address.Type.Enum do
  @vsn 1.0
  @nmid_index 204
  @sref "address-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        other: 1,
        home: 2,
        landmark: 3,
        business: 4,
        auto: 5,
      ]
end
