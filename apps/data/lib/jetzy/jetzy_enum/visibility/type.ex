#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Visibility.Type.Enum do
  @vsn 1.0
  @nmid_index 296
  @sref "visibility-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        public: 1,
        private: 2,
        friends: 3,
        friends_of_friends: 4,
        friend_group: 5,
        group: 6,
        private_interest: 7,
        select: 8,
      ],
      default: :public
end
