#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Data.Source.Type.Enum do
  @vsn 1.0
  @nmid_index 225
  @sref "data-source-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        hotel: 1,
        restaurant: 2,
        travel: 3,
        activity: 4
      ]
end
