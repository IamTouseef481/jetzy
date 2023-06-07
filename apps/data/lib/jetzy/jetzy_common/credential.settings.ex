#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 Travellers Connect, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Credential.Settings do
  defmodule TypeHandler do
    require  Noizu.DomainObject
    Noizu.DomainObject.noizu_type_handler()

    #--------------------------------------
    #
    #--------------------------------------
    def dump(field, _segment, v, _type, %{schema: JetzySchema.Database}, _context, _options) do
      [
        {:query_key, v.__struct__.query_key},
        {field, v}
      ]
    end
    def dump(field, segment, v, type, layer, context, options) do
      super(field, segment, v, type, layer, context, options)
    end
  end
end
