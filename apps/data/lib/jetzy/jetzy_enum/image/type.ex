#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Image.Type.Enum do
  @vsn 1.0
  @nmid_index 295
  @sref "image-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        profile: 1,
        background: 2,
        post: 3,
        user_upload: 4,
        logo: 5,
        moment: 6,
        shout_out: 7,
        comment: 8,
        place: 9,
        monument: 10,
        other: 11,
        interest: 12,
        profile_image: 13,
        offer_image: 14,
        default_profile_image: 15,
      ]
end
