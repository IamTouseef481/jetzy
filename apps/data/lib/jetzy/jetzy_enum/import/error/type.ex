#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Import.Error.Type.Enum do
  @vsn 1.0
  @nmid_index 306
  @sref "import-error-type"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        other: 0,
        text_encoding: 1,
        image_upload: 2,
        blur_hash: 3,
      ],
      default: :other
end
