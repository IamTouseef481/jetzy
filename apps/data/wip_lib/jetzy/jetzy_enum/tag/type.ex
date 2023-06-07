#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Tag.Type.Enum do
  @vsn 1.0
  @nmid_index 290
  @sref "tag-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        poster: 1,
        subject: 2,
        community: 3,
        system: 4,
      ],
      default: :none
end
