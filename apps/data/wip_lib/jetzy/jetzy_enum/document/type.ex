#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Document.Type.Enum do
  @vsn 1.0
  @nmid_index 200
  @sref "document-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        other: 1,
        menu: 2,
        form: 3,
        map: 4,
        brochure: 5,
      ]
end
