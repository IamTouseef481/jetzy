#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Relationship.Type.Enum do
  @vsn 1.0
  @nmid_index 276
  @sref "relationship-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        dating: 1,
        its_complicated: 2,
        engaged: 3,
        married: 4,
        domestic_partner: 5,
        poly: 6,
      ]
end
