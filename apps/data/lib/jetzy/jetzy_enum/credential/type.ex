#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Credential.Type.Enum do
  @vsn 1.0
  @nmid_index 223
  @sref "credential-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        firebase: 1,
        jetzy_legacy: 2,
        jetzy_legacy_session: 3,
        jetzy_sign_in: 4,
        oauth: 5,
        social: 6,
      ]
end
