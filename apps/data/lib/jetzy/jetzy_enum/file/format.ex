#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.File.Format.Enum do
  @vsn 1.0
  @nmid_index 235
  @sref "file-format"
  use Jetzy.ElixirScaffolding.EnumEntity,
      values: [
        none: 0,
        other: 1,
        rtf: 2,
        txt: 3,
        csv: 4,
        mpeg: 5,
        doc: 6,
        docx: 7,
        pdf: 8,
        jpg: 9,
        png: 10,
        bmp: 11,
        tiff: 12,
        gif: 13,
      ]
end
