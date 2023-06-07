#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Business.Type.Enum do
  @vsn 1.0
  @nmid_index 209
  @sref "business-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        restaurant: 1,
        car_rental: 2,
        night_club: 3,
        translation: 4,
        tour_guide: 5,
        rental: 6
      ]
end
