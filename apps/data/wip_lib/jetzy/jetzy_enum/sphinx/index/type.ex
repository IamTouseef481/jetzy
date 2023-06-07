#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Sphinx.Index.Type.Enum do
  @vsn 1.0
  @nmid_index 283
  @sref "sphinx-index-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        not_indexed: 1,
        real_time: 2,
        delta: 3,
        primary: 4,
      ],
      default: :not_indexed
end
