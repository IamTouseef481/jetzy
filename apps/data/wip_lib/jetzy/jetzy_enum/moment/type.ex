#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Moment.Type.Enum do
  @vsn 1.0
  @nmid_index 260
  @sref "moment-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        text: 1,
        image: 2,
        video: 3,
        audio: 4,
        media: 5,
        link: 6,
      ]
end
