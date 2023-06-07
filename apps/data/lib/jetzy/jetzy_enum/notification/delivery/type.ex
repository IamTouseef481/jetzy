#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Notification.Delivery.Type.Enum do
  @vsn 1.0
  @nmid_index 261
  @sref "notification-delivery-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        disabled: 1,
        digest: 2,
        send: 3,
      ]
end