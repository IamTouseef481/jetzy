#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Source.Enum do
  @vsn 1.0
  @nmid_index 252
  @sref "location-source"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        google: 1,
        baidu: 2,
        apple: 3,
        bing: 4,
        legacy: 5,
        iso: 6,
      ]
end
