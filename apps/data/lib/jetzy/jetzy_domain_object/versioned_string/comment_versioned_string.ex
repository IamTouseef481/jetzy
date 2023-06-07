#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CommentVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-comment-str"

  defmodule Entity do
    @nmid_index 131
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    @source_field :comment_versioned_string
    use Jetzy.VersionedStringBehavior.Repo
  end

end
