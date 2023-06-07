#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Business.DressCode.Enum do
  @vsn 1.0
  @nmid_index 206
  @sref "dress-code"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        dress_casual: 1,
        casual: 2,
        black_tie: 3,
        white_tie: 4,
        other: 5
      ]
end
