#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Social.Type.Enum do
  @vsn 1.0
  @nmid_index 342
  @sref "social-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        apple: 1,
        facebook: 2,
        google: 3,
        linkedin: 4,
      ]
end
