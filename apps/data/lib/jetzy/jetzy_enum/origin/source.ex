#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Origin.Source.Enum do
  @vsn 1.0
  @nmid_index 267
  @sref "origin"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        jetzy: 1,
        crisis: 2,
        legacy: 3,
        tanbits: 4,
      ]
end
