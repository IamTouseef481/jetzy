#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Moderation.Type.Enum do
  @vsn 1.0
  @nmid_index 259
  @sref "moderation-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        system_flagged: 1,
        community_flagged: 2,
        legal_review: 3,
        fact_check: 4,
        content_review: 5,
        i8n_review: 6,
      ]
end
