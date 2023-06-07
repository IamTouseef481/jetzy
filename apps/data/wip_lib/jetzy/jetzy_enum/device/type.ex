#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Device.Type.Enum do
  @vsn 1.0
  @nmid_index 229
  @sref "device-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        iphone: 1,
        android: 2,
        ipad: 3,
        tablet: 4,
        browser: 5,
        iwatch: 6,
        android_watch: 7
      ]
end
