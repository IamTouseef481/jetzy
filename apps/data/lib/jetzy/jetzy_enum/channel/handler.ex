#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Handler.Enum do
  @vsn 1.0
  @nmid_index 211
  @sref "channel-handler"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        {:none, 0},
        {JetzyModule.Channel.Handler.Email, 1},
        {JetzyModule.Channel.Handler.QuickBlox, 2},
        {JetzyModule.Channel.Handler.Push, 3},
        {JetzyModule.Channel.Handler.SMS, 4},
        {JetzyModule.Channel.Handler.Voice, 5},
      ]
end
