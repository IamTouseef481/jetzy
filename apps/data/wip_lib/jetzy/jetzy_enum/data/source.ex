#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Data.Source.Enum do
  @vsn 1.0
  @nmid_index 224
  @sref "data-source"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        select: 1,
        airbnb: 2,
        google: 3,
        baidu: 4,
        bing: 5
      ]
end
