#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Interaction.Type.Enum do
  @vsn 1.0
  @nmid_index 246
  @sref "interaction-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        view: 1,
        comment: 2,
        emote: 3,
        share: 4
      ]
end
