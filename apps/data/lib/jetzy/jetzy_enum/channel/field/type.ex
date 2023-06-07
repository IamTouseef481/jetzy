#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Field.Type.Enum do
  @vsn 1.0
  @nmid_index 210
  @sref "channel-field-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        email: 1,
        number: 2,
        firebase_token: 3,
        quick_blox: 4,
        verified: 5,
        locale: 6,
        quick_blox_user: 7,
        quick_blox_auth: 8,
      ]
end
