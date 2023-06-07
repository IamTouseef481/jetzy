#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedImageString.History do
  use Jetzy.VersionedString.HistoryBehavior
  @vsn 1.0
  @sref "v-img-str-h"

  defmodule Entity do
    @nmid_index 156
    use Jetzy.VersionedString.HistoryBehavior.Entity,
        source: :versioned_image_string
  end

  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end
end
