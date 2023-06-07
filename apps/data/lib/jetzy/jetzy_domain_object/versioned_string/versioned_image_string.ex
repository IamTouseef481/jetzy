#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedImageString do
  use Jetzy.VersionedStringBehavior
  @vsn 1.0
  @sref "v-img-str"

  defmodule Entity do
    @nmid_index 155
    use Jetzy.VersionedStringBehavior.Entity
  end

  defmodule Repo do
    @source_field :versioned_image_string
    use Jetzy.VersionedStringBehavior.Repo
  end
end
