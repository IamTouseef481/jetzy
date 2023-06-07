#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Gender.Enum do
  @vsn 1.0
  @nmid_index 237
  @sref "gender"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        male: 1,
        female: 2,
        trans_male: 3,
        trans_female: 4,
        intersex: 5,
        gender_fluid: 6,
        non_binary: 7,
        other: 8,
      ]
end
