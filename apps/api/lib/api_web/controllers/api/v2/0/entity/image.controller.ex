#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------

if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule JetzyApi.V2_0.Entity.Image.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  use JetzyElixir.ApiBehaviour,
      entity_module: Jetzy.Entity.Image.Entity

end

end