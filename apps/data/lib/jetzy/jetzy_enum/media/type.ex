#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Media.Type.Enum do
  @vsn 1.0
  @nmid_index 256
  @sref "media-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        unknown: 0,
        text: 1,
        image: 2,
        video: 3,
        audio: 4,
        media: 5,
        link: 6,
      ],
      default: :text
end
