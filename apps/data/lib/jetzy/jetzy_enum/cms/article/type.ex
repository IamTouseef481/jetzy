#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Type.Enum do
  @vsn 1.0
  @nmid_index 217
  @sref "cms-article-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        snippet: 1,
        post: 2,
        crisis_post: 3,
        entity_description: 4,
        generic: 5,
        moment: 6,
        shout_out: 7,
        description: 8,
      ]
end
