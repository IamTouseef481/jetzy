#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Contact.Type.Enum do
  @vsn 1.0
  @nmid_index 220
  @sref "contact-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        guardian: 1,
        friend: 2,
      ]
end
