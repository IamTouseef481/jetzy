#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.TopologyProvider do
  @behaviour Noizu.MnesiaVersioning.TopologyBehaviour

  def mnesia_nodes() do
    {:ok, [node()]}
  end

  def database() do
    [JetzySchema.Database]
  end
end
