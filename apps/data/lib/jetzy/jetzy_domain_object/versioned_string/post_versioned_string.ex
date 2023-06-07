#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.PostVersionedString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-post-str"

  defmodule Entity do
    @nmid_index 137
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    @source_field :post_versioned_string
    use Jetzy.VersionedStringBehavior.Repo
  end

end
