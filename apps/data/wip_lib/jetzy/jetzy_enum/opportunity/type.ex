#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Opportunity.Type.Enum do
  @vsn 1.0
  @nmid_index 266
  @sref "opportunity-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        internship: 1,
        part_time: 2,
        full_time: 3,
      ]
end
