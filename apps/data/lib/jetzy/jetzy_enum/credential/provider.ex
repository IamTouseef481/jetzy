#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Credential.Provider.Enum do
  @vsn 1.0
  @nmid_index 222
  @sref "credential-provider"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        firebase: 1,
        legacy: 2,
        jetzy: 3,
        facebook: 4,
        linkedin: 5,
        twitter: 6,
        pinterest: 7,
        instagram: 8,

      ]
end
