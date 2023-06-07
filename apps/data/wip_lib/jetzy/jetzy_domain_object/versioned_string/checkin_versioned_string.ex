#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CheckInVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-checkin-str"

  defmodule Entity do
    @nmid_index 129
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    use Jetzy.VersionedStringBehavior.Repo
  end

end
