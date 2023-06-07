#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.SearchVisibility.Level.Enum do
  @vsn 1.0
  @nmid_index 278
  @sref "search-visibility-level"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        restricted: 0,
        staff: 1,
        private: 2,
        public: 3,
      ],
      default: :restricted
end
