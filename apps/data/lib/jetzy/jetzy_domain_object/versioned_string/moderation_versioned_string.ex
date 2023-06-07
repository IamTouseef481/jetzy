#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.ModerationVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-moderation-str"

  defmodule Entity do
    @nmid_index 135
    use Jetzy.VersionedStringBehavior.Entity,
        source: :moderation_versioned_string
  end

  defmodule Repo do
    @source_field :moderation_versioned_string
    use Jetzy.VersionedStringBehavior.Repo
  end
end
