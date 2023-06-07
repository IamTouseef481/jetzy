#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.CMS.Article.Revision.Attribute.Value.Type.Enum do
  @vsn 1.0
  @nmid_index 215
  @sref "cms-arev-attr-vtype"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        integer: 0,
        string: 1,
        double: 3,
        atom: 4,
      ],
      default: :integer
end
