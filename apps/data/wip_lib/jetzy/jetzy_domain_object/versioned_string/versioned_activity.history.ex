#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedActivity.History do
  use Jetzy.VersionedString.HistoryBehavior
  @vsn 1.0
  @sref "v-activity-str-h"

  defmodule Entity do
    @nmid_index 148
    use Jetzy.VersionedString.HistoryBehavior.Entity
  end

  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end
end
