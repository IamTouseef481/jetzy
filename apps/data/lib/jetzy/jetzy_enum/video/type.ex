#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Video.Type.Enum do
  @vsn 1.0
  @nmid_index 245
  @sref "video-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        profile: 1,
        background: 2,
        post: 3,
        user_upload: 4,
        animated_logo: 5,
        comment: 8,
        place: 9,
        monument: 10,
        other: 11,
      ]
end
