#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Share.Event.Type.Enum do
  @vsn 1.0
  @nmid_index 280
  @sref "share-event-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        share: 1,
        quote_share: 2,
        unshare: 3,
        system_remove: 4,
        moderator_remove: 5,
      ],
      default: :none
end
