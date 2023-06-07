#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Type.Enum do
  @vsn 1.0
  @nmid_index 253
  @sref "location-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        other: 1,
        address: 2,
        neighborhood: 3,
        municipality: 4,
        city: 5,
        state: 6,
        country: 7,
        region: 8,
      ]
end
