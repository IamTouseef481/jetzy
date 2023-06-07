#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.UserPanicVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-user-panic-str"

  defmodule Entity do
    @nmid_index 143
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    @source_field :user_panic_versioned_string
    use Jetzy.VersionedStringBehavior.Repo
  end
end
