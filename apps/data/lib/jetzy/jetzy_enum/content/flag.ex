#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Content.Flag.Enum do
  @vsn 1.0
  @nmid_index 221
  @sref "content-flag"
  use Jetzy.ElixirScaffolding.EnumEntity,
      versioning: nil,
      values: [
        none: 0,
        community_flag: 1,
        system_flag: 2,
        content_flag: 3,
        spam_flag: 4,
        abuse_flag: 5,
        fact_check_flag: 6,
      ]
end
