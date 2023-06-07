#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Zone.Enum do
  @vsn 1.0
  @nmid_index 254
  @sref "location-zone"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        north_america: 1,
        south_america: 2,
        hawaii: 3,
        europe: 4,
        africa: 5,
        south_east_asia: 6,
        asia: 7,
        middle_east: 8,
        australia: 9,
        green_land: 10,
      ]
end
