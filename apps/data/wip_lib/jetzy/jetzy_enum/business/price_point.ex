#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Business.PricePoint.Enum do
  @vsn 1.0
  @nmid_index 207
  @sref "price-point"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        "$": 1,
        "$$": 2,
        "$$$": 3,
        "$$$$": 4,
        market: 5
      ]
end
