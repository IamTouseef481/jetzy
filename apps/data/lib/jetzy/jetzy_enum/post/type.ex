#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Type.Enum do
  @vsn 1.0
  @nmid_index 271
  @sref "post-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        post: 1,
        moment: 2,
        question: 3,
        recommendation: 4,
      ],
      default: :post
end
