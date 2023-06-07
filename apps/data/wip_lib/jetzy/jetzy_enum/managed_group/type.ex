#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.ManagedGroup.Type.Enum do
  @vsn 1.0
  @nmid_index 255
  @sref "managed-group-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: {0, "Default - Preconfigured Managed Group"}
      ]
end
