#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Relative.Type.Enum do
  @vsn 1.0
  @nmid_index 277
  @sref "relative-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        parent_guardian: 1,
        child: 2,
        grand_parent: 3,
        cousin: 4,
        nephew_niece: 5,
        aunt_uncle: 6,
        extended_family: 7,
      ]
end
