#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.UserAboutVersionedString.History do
  use Jetzy.VersionedString.HistoryBehavior
  @vsn 1.0
  @sref "v-user-about-str-h"

  defmodule Entity do
    @nmid_index 140
    use Jetzy.VersionedString.HistoryBehavior.Entity,
        source: :user_about_versioned_string
  end

  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end
end
