#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Group.SignUp.Type.Enum do
  @vsn 1.0
  @nmid_index 244
  @sref "group-sign-up-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        invite: 1,
        referral: 2,
        request: 3,
        open: 4,
      ]
end
