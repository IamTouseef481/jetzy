#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Share.Type.Enum do
  @vsn 1.0
  @nmid_index 281
  @sref "share-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        group: 1,
      ],
      default: :none
end
