#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.UserPanicVersionedString.History do
  use Jetzy.VersionedString.HistoryBehavior
  @vsn 1.0
  @sref "v-user-panic-str-h"

  defmodule Entity do
    @nmid_index 144
    use Jetzy.VersionedString.HistoryBehavior.Entity,
        source: :user_panic_versioned_string
  end

  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end
end
