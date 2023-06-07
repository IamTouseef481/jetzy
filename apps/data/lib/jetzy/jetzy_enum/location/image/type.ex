#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Image.Type.Enum do
  @vsn 1.0
  @nmid_index 250
  @sref "location-image-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
      ]
end
