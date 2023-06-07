#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Type.Enum do
  @vsn 1.0
  @nmid_index 212
  @sref "channel-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        email: 1,
        push: 2,
        sms: 3,
        phone: 4,
        web_hook: 5,
        fax: 6,
        website: 7,
        face_book: 8,
        quick_blox: 9,
      ]
end
