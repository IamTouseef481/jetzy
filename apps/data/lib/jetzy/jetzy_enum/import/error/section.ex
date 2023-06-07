#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Import.Error.Section.Enum do
  @vsn 1.0
  @nmid_index 305
  @sref "import-error-section"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        other: 0,
        path: 1,
        post_title: 2,
        post_body: 3,
        comment_body: 4,
        image: 5,
        first_name: 6,
        last_name: 7,
        school: 8,
        employer: 9,
        about: 10,
        bio: 11,
        unknown: 12,
        profile: 13,
        title: 14,
        description: 15,
        post: 16,
        comment: 17,
      ],
      default: :other
end
