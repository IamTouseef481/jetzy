#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Tag.State.Enum do
  @vsn 1.0
  @nmid_index 289
  @sref "tag-state"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        disabled: 0,
        approved: 1,
        suggested: 2,
        removed: 3,
        pending: 4,
      ],
      default: :disabled
end
