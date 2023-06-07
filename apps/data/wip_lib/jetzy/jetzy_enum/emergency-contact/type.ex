#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.EmergencyContact.Type.Enum do
  @vsn 1.0
  @nmid_index 230
  @sref "emergency-contact-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        guardian: 1,
        significant_other: 2,
        lawyer: 3,
        friend: 4,
        travel_companion: 5,
        other: 6
      ]
end
