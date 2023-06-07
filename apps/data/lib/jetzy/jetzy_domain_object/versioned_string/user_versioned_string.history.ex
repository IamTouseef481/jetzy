#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.UserVersionedString.History do
  use Jetzy.VersionedString.HistoryBehavior
  @vsn 1.0
  @sref "v-user-str-h"

  defmodule Entity do
    @nmid_index 146
    use Jetzy.VersionedString.HistoryBehavior.Entity,
        source: :user_versioned_string

  end

  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end
end
