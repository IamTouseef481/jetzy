#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Comment.Event.Type.Enum do
  @vsn 1.0
  @nmid_index 218
  @sref "comment-event-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        comment: 1,
        uncomment: 2,
        system_remove: 3,
        moderator_remove: 4,
      ],
      default: :none
end
